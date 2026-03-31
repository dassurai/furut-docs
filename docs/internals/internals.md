# ⚙️ Database Internals (Auto Generated)

## ⚡ Triggers

```sql
CREATE TRIGGER trg_kyc_verified AFTER UPDATE ON public.account_kyc_documents FOR EACH ROW EXECUTE FUNCTION public.kyc_verified_trigger();
```

```sql
CREATE TRIGGER trg_prevent_owner_delete BEFORE DELETE ON public.account_members FOR EACH ROW EXECUTE FUNCTION public.prevent_owner_delete();
```

```sql
CREATE TRIGGER trg_prevent_owner_update BEFORE UPDATE ON public.account_members FOR EACH ROW EXECUTE FUNCTION public.prevent_owner_role_update();
```

```sql
CREATE TRIGGER trg_payout_verified AFTER UPDATE ON public.account_payout_profiles FOR EACH ROW EXECUTE FUNCTION public.payout_verified_trigger();
```

```sql
CREATE TRIGGER account_created_audit AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.account_created_trigger();
```

```sql
CREATE TRIGGER trg_account_created AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.audit_account_created();
```

```sql
CREATE TRIGGER trg_assign_default_subscription AFTER INSERT ON public.accounts FOR EACH ROW EXECUTE FUNCTION public.assign_default_subscription();
```

```sql
CREATE TRIGGER tr_address_geo_sync BEFORE INSERT OR UPDATE OF latitude, longitude ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.handle_address_geography();
```

```sql
CREATE TRIGGER tr_update_address_location BEFORE INSERT OR UPDATE OF latitude, longitude ON public.addresses FOR EACH ROW EXECUTE FUNCTION public.update_address_location();
```

```sql
CREATE TRIGGER trg_sync_property_location BEFORE INSERT OR UPDATE OF address_id ON public.properties FOR EACH ROW EXECUTE FUNCTION public.sync_property_location();
```

```sql
CREATE TRIGGER trg_user_profiles_updated_at BEFORE UPDATE ON public.user_profiles FOR EACH ROW EXECUTE FUNCTION public.update_timestamp();
```

