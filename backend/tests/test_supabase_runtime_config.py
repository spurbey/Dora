"""
Tests for Supabase runtime configuration validation.
"""

import pytest

from app.services.storage_service import validate_supabase_runtime_configuration


def test_validate_runtime_config_normalizes_quoted_values():
    diagnostics = validate_supabase_runtime_configuration(
        environment="development",
        supabase_url=' "https://example.supabase.co/" ',
        service_role_key=' "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.abc.def" ',
        strict=False,
    )

    assert diagnostics["url_valid"] is True
    assert diagnostics["key_format"] == "jwt"
    assert diagnostics["url_sanitized"] is True
    assert diagnostics["key_sanitized"] is True


def test_validate_runtime_config_rejects_sb_secret_in_strict_mode():
    with pytest.raises(RuntimeError, match="sb_secret format"):
        validate_supabase_runtime_configuration(
            environment="production",
            supabase_url="https://example.supabase.co",
            service_role_key="sb_secret_xxx",
            strict=True,
        )
