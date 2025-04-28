"""
Token cleanup script for expired refresh tokens.

This can be run as a standalone script or scheduled using a task scheduler.
For production, consider setting up a cron job to run this script periodically.

Example cron entry (daily at 2 AM):
0 2 * * * /path/to/python /path/to/token_cleanup.py
"""

import logging
from auth.database import cleanup_expired_tokens

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)

def cleanup_tokens():
    """Clean up expired refresh tokens from the database"""
    try:
        result = cleanup_expired_tokens()
        logger.info(f"Successfully removed {result.deleted_count} expired tokens")
        return result.deleted_count
    except Exception as e:
        logger.error(f"Error cleaning up expired tokens: {str(e)}")
        return 0

if __name__ == "__main__":
    deleted_count = cleanup_tokens()
    print(f"Removed {deleted_count} expired tokens") 