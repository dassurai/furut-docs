# 🧠 System Flows (Readable Intelligence)

## 🔹 ACCOUNT

1. Trigger: account_kyc_documents
   → Verify identity
   → accounts
   → Create related entity
   → Log system event
   → Assign related data
   → account_subscriptions

2. Trigger: account_members
   → Block restricted action

3. Trigger: account_members
   → Update related data

4. Trigger: account_payout_profiles
   → Process payout verification
   → accounts
   → Create related entity
   → Log system event
   → Assign related data
   → account_subscriptions

---

## 🔹 LOCATION

1. Trigger: addresses
   → Execute system logic

2. Trigger: addresses
   → Update related data

---

## 🔹 USER

1. Trigger: user_profiles
   → Update related data

---

