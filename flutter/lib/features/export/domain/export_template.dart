/// Domain-level video template options for export flow.
///
/// Keep this enum independent from generated API DTOs so UI/provider layers
/// do not depend on transport types.
enum ExportTemplate {
  classic,
  cinematic,
}
