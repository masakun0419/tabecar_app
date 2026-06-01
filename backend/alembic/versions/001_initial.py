"""Initial schema

Revision ID: 001
Revises:
Create Date: 2026-06-01
"""

from typing import Sequence, Union

from alembic import op

revision: str = "001"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Schema is applied via schema.sql on first Docker init.
    pass


def downgrade() -> None:
    pass
