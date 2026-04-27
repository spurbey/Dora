This version is strong and close to implementation-ready.  
I’d mark it **ready with 5 final adjustments**:

1. **Do not silently drop `RuntimeError` in async task helpers**
- In `start_v2_session` and `trips.py` seed helper, log the runtime error path too.
- Otherwise failures become invisible.

2. **Make fire-and-forget helpers reusable**
- Put both `_best_effort_advisory_enrich` and `_best_effort_brain_seed` in one shared utility module.
- Avoid duplicate task/session boilerplate.

3. **Clarify empty user-metadata predicate with `notification_enabled`**
- Your empty definition ignores this field.
- Decide explicitly: either include it in emptiness logic or document it as intentionally excluded.

4. **Execution order tweak**
- `5F` (normal lane using `PreCreateScreen` mode) should run **after 5A + route updates**, and ideally after regen only if that screen uses regenerated models.
- Otherwise you risk temporary navigation dead paths.

If you include those, this plan is coherent end-to-end and safe to execute.