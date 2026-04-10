# System V2 Documentation Index

This directory contains the clean-slate Live System V2 design documents.

## How to read

1. Start with the master blueprint:
- [Master Blueprint](./subsystem_specs/master-blueprint.md)

2. Then move to subsystem specs in order:
- [Subsystem Specs Index](./subsystem_specs/README.md)

3. Then use the rollout control document:
- [Execution Plan V2](./execution-plan-v2.md)
4. Day-to-day delivery tracker:
- [Implementation Order Checklist](./IMPLEMENTATION-ORDER-CHECKLIST.md)
5. Locked implementation constants:
- [Contract Freeze V2](./contract-freeze-v2.md)

## Authoring rule

1. `master-blueprint.md` defines the high-level architecture and non-negotiable policies.
2. Subsystem specs define module-level contracts and must reference the blueprint.
3. Contract docs (schema/API/state-machine) must reference the relevant subsystem spec.
4. Execution plan governs phase gates, kill-list, and rollout controls.

