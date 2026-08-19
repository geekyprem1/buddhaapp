# Admin bootstrap

Creates the first Super Admin. See `functions/README.md` for the full
procedure.

```powershell
node tools/admin/bootstrap_super_admin.js --email=you@dhammapath.app --password="choose-a-long-password" --name="Your Name"
```

Requires `firebase login`. Never point this at `dhamma-path-prod` without
`--allow-prod`.
