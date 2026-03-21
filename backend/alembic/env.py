"""
Alembic migration environment configuration.

This file is used by Alembic to:
- Connect to the database
- Detect model changes
- Generate migrations
- Apply migrations

Important:
    - Imports all models for autogenerate to work
    - Uses SUPABASE_DB_URL from settings
    - Supports both online and offline migrations
"""

from logging.config import fileConfig
from sqlalchemy import engine_from_config
from sqlalchemy import pool
from alembic import context
from alembic.operations import ops

# Import app config and models
from app.config import settings
from app.database import Base

# Import all model modules so Base.metadata is complete for autogenerate.
import app.models  # noqa: F401

# Alembic Config object
config = context.config

# Setup Python logging
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

# Set database URL from settings
config.set_main_option("sqlalchemy.url", settings.SUPABASE_DB_URL)

# Model metadata for autogenerate
target_metadata = Base.metadata

# PostGIS extension-managed objects should not be part of app schema drift checks.
POSTGIS_EXTENSION_TABLES = {
    "spatial_ref_sys",
    "geography_columns",
    "geometry_columns",
    "raster_columns",
    "raster_overviews",
}

ALEMBIC_INTERNAL_TABLES = {"alembic_version"}

IGNORED_TABLES = POSTGIS_EXTENSION_TABLES | ALEMBIC_INTERNAL_TABLES


def _is_comment_only_alter_column(op_):
    if not isinstance(op_, ops.AlterColumnOp):
        return False

    return (
        op_.modify_comment not in (None, False)
        and op_.modify_nullable is None
        and op_.modify_type is None
        and op_.modify_server_default is False
        and op_.modify_name is None
    )


def _strip_comment_only_ops(op_container):
    if not hasattr(op_container, "ops"):
        return

    filtered_ops = []
    for op_ in op_container.ops:
        if isinstance(op_, ops.ModifyTableOps):
            _strip_comment_only_ops(op_)
            if op_.ops:
                filtered_ops.append(op_)
            continue

        if _is_comment_only_alter_column(op_):
            continue

        filtered_ops.append(op_)

    op_container.ops = filtered_ops


def process_revision_directives(context_, revision, directives):
    if not directives:
        return

    script = directives[0]
    for upgrade_ops in script.upgrade_ops_list:
        _strip_comment_only_ops(upgrade_ops)
    for downgrade_ops in script.downgrade_ops_list:
        _strip_comment_only_ops(downgrade_ops)


def include_object(object_, name, type_, reflected, compare_to):
    if type_ == "table" and name in IGNORED_TABLES:
        return False

    # Filter child schema objects that belong to ignored extension tables.
    table_name = None
    if type_ in {"index", "unique_constraint", "foreign_key_constraint", "check_constraint"}:
        parent_table = getattr(object_, "table", None)
        if parent_table is None and compare_to is not None:
            parent_table = getattr(compare_to, "table", None)
        if parent_table is not None:
            table_name = parent_table.name

    if table_name in IGNORED_TABLES:
        return False

    return True


def run_migrations_offline() -> None:
    """
    Run migrations in 'offline' mode.
    
    Generates SQL file without database connection.
    Useful for production deployments where direct DB access
    is restricted.
    """
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        include_object=include_object,
        process_revision_directives=process_revision_directives,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()


def run_migrations_online() -> None:
    """
    Run migrations in 'online' mode.
    
    Creates actual database connection and applies migrations.
    Standard mode for development.
    """
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            include_object=include_object,
            process_revision_directives=process_revision_directives,
        )

        with context.begin_transaction():
            context.run_migrations()


# Run appropriate migration mode
if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
