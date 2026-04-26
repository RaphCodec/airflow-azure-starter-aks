from flask_appbuilder.security.manager import AUTH_OAUTH
import os
from airflow.providers.fab.auth_manager.security_manager.override import FabAirflowSecurityManagerOverride
from airflow.utils.log.logging_mixin import LoggingMixin
import requests

# Set up Redis for Rate Limiting
RATELIMIT_ENABLED = True
# Using fixed window for simplicity and memory optimization. Change as needed.
RATELIMIT_STRATEGY = "fixed-window" 
RATELIMIT_DEFAULT = "200/hour;50/minute"
RATELIMIT_APPLICATION = "2000/day"

AUTH_TYPE = AUTH_OAUTH
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "Public"
AUTH_ROLES_SYNC_AT_LOGIN = False  # Changed to False - manage roles in Airflow

OAUTH_PROVIDERS = [
    {
        "name": "azure",
        "icon": "fa-windows",
        "token_key": "access_token",
        "remote_app": {
            "base_url": "https://graph.microsoft.com/v1.0/",
            "request_token_params": {"scope": "openid profile email User.Read GroupMember.Read.All"},
            "authorize_params": {"scope": "openid profile email User.Read GroupMember.Read.All"},
            "access_token_url": f"https://login.microsoftonline.com/{os.getenv('AAD_TENANT_ID')}/oauth2/v2.0/token",
            "authorize_url": f"https://login.microsoftonline.com/{os.getenv('AAD_TENANT_ID')}/oauth2/v2.0/authorize",
            "jwks_uri": f"https://login.microsoftonline.com/{os.getenv('AAD_TENANT_ID')}/discovery/v2.0/keys",
            "api_base_url": "https://graph.microsoft.com/v1.0/",
            "server_metadata_url": f"https://login.microsoftonline.com/{os.getenv('AAD_TENANT_ID')}/v2.0/.well-known/openid-configuration",
            "request_token_url": None,
            "client_id": os.getenv('AAD_CLIENT_ID'),
            "client_secret": os.getenv('AAD_CLIENT_SECRET'),
            "client_kwargs": {"scope": "openid profile email User.Read GroupMember.Read.All"},
        },
    },
]

class AzureOAuth(FabAirflowSecurityManagerOverride, LoggingMixin):
    
    def is_user_in_authorized_group(self, access_token):
        """Check if user is member of authorized Azure AD group"""
        authorized_group_id = os.getenv('AAD_AUTHORIZED_GROUP_ID')
        if not authorized_group_id:
            self.log.warning("AAD_AUTHORIZED_GROUP_ID not set, allowing all users")
            return True
        
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            response = requests.get(
                'https://graph.microsoft.com/v1.0/me/memberOf',
                headers=headers
            )
            response.raise_for_status()
            groups = response.json().get('value', [])
            
            for group in groups:
                if group.get('id') == authorized_group_id:
                    return True
            
            self.log.warning(f"User not in authorized group: {authorized_group_id}")
            return False
        except Exception as e:
            self.log.error(f"Error checking group membership: {e}")
            return False
    
    def is_user_in_admin_group(self, access_token):
        """Check if user is member of admin Azure AD group"""
        admin_group_id = os.getenv('AAD_ADMIN_GROUP_ID')
        if not admin_group_id:
            self.log.info("AAD_ADMIN_GROUP_ID not set, no admin group check")
            return False
        
        try:
            headers = {'Authorization': f'Bearer {access_token}'}
            response = requests.get(
                'https://graph.microsoft.com/v1.0/me/memberOf',
                headers=headers
            )
            response.raise_for_status()
            groups = response.json().get('value', [])
            
            for group in groups:
                if group.get('id') == admin_group_id:
                    return True
            
            return False
        except Exception as e:
            self.log.error(f"Error checking admin group membership: {e}")
            return False

    def oauth_user_info(self, provider, response=None):
        """Override to check group membership before allowing login"""
        if provider == 'azure':
            access_token = response.get('access_token')
            
            # Check group membership - if not in group, deny access
            if not self.is_user_in_authorized_group(access_token):
                raise Exception("User is not a member of the authorized Azure AD group")
            
            # Get user info (roles assigned only on initial user creation)
            me = self.get_azure_user_info(response)
            return me
        return super().oauth_user_info(provider, response)
    
    def get_azure_user_info(self, response=None):
        """Fetch user info from Microsoft Graph API and assign role based on admin list"""
        try:
            access_token = response.get('access_token')
            headers = {'Authorization': f'Bearer {access_token}'}
            
            # Get user info from Microsoft Graph
            user_response = requests.get(
                'https://graph.microsoft.com/v1.0/me',
                headers=headers
            )
            user_response.raise_for_status()
            user_data = user_response.json()
            
            # Get user email
            user_email = user_data.get('mail') or user_data.get('userPrincipalName', '')
            if not user_email:
                self.log.error("Azure user info missing email/userPrincipalName")
                raise Exception("Missing user email from Azure profile")
            
            # Check if user is in admin group for initial role assignment
            is_admin = self.is_user_in_admin_group(response.get('access_token'))
            
            # Determine role based on admin group membership
            if is_admin:
                default_role = "Admin"
                self.log.info(f"User {user_email} is in admin group, granting Admin role")
            else:
                default_role = "Public"
                self.log.info(f"User {user_email} not in admin group, granting Public role")
            
            return {
                "name": user_data.get('displayName', ''),
                "email": user_email,
                "first_name": user_data.get('givenName', ''),
                "last_name": user_data.get('surname', ''),
                "id": user_data.get('id', ''),
                "username": user_email,
                "role_keys": [default_role]
            }
        except Exception as e:
            import traceback
            traceback.print_exc()
            self.log.error(f"Failed to get Azure user info: {e}")
            raise

    def auth_user_oauth(self, userinfo):
        """Override to ensure correct role assignment on user creation"""
        role_name = userinfo.get('role_keys', ['Public'])[0] if userinfo.get('role_keys') else 'Public'
        role = self.find_role(role_name)
        if not role:
            self.log.warning(f"Role {role_name} not found, using Public")
            role = self.find_role('Public')
        user = self.find_user(email=userinfo.get('email'))
        if not user:
            user = self.add_user(
                username=userinfo.get('username'),
                first_name=userinfo.get('first_name', ''),
                last_name=userinfo.get('last_name', ''),
                email=userinfo.get('email'),
                role=role
            )
            if user:
                self.log.info(f"Created new user {userinfo.get('username')} with role {role_name}")
        else:
            self.log.info(f"User {userinfo.get('username')} already exists")
        return user

SECURITY_MANAGER_CLASS = AzureOAuth