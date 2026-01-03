# PAYMENT SETUP GUIDE - GENESIS PASS

**PURPOSE:** Configure payment infrastructure for $500 Genesis Pass sales  
**TARGET:** Collect $10,000 by 01/01/2026  
**PRIORITY:** CRITICAL - Must be ready before Dec 26 launch

---

## RECOMMENDED PAYMENT PLATFORMS

### Option 1: Stripe (RECOMMENDED)

**Pros:**
- ✅ Professional payment processing
- ✅ Easy link sharing for DMs
- ✅ Automatic receipts
- ✅ Dashboard for tracking
- ✅ Lower fees (2.9% + $0.30)
- ✅ Fraud protection

**Cons:**
- ⚠️ Requires business verification
- ⚠️ 2-7 day payout delays

**Setup Steps:**

1. **Create Stripe Account**
   - Go to stripe.com
   - Sign up for business account
   - Complete verification (SSN/EIN required)
   - Connect bank account

2. **Create Payment Link**
   - Go to Payment Links in Stripe dashboard
   - Click "Create payment link"
   - Set product name: "Genesis Pass - Founding Creator"
   - Set price: $500 USD
   - Select "One-time payment" (NOT subscription)
   - Add description: "Founding Creator Genesis Pass for Nexus COS. Closes 01/01/2026. No refunds."
   - Enable: "Collect customer email"
   - Disable: Quantity adjustments
   - Save and copy link

3. **Test Payment Link**
   - Use Stripe test mode first
   - Test credit card: 4242 4242 4242 4242
   - Verify receipt email sends
   - Check dashboard updates
   - Switch to live mode

4. **Configure Notifications**
   - Enable email notifications for successful payments
   - Set up webhook (optional, for advanced tracking)
   - Test notification delivery

**Link Format:**
```
https://buy.stripe.com/[unique-id]
```

**Use This Link In DMs:**
```
Payment via Stripe: https://buy.stripe.com/[your-link]

$500 one-time. No recurring charges.
Receipt sent immediately after payment.
```

---

### Option 2: PayPal

**Pros:**
- ✅ Familiar to most buyers
- ✅ Fast setup (no business verification)
- ✅ Instant access to funds
- ✅ Easy refunds (if needed)

**Cons:**
- ⚠️ Higher fees (3.49% + $0.49)
- ⚠️ Less professional appearance
- ⚠️ More buyer protection issues

**Setup Steps:**

1. **Create PayPal Business Account**
   - Go to paypal.com
   - Create business account
   - Verify email and bank

2. **Create PayPal.me Link**
   - Go to paypal.me/[yourname]
   - OR use invoice feature

3. **Create Invoice Template**
   - Go to Invoicing in PayPal
   - Create invoice for $500
   - Title: "Genesis Pass - Founding Creator"
   - Add terms: "No refunds. Closes 01/01/2026."
   - Save as template
   - Send individual invoices to buyers

**Link Format:**
```
https://paypal.me/[yourname]/500
```

**Or send individual invoices via email**

---

### Option 3: Venmo (For Fast/Casual Buyers)

**Pros:**
- ✅ Instant setup
- ✅ No fees for personal accounts
- ✅ Fast transfers
- ✅ Familiar to younger audience

**Cons:**
- ⚠️ Less professional
- ⚠️ $299.99 weekly limit (will need business account)
- ⚠️ No automatic receipts
- ⚠️ Limited tracking

**Setup:**
- Download Venmo app
- Create account
- Upgrade to business account (for higher limits)
- Share username: @yourname

**NOT RECOMMENDED for Genesis Pass (too casual)**

---

### Option 4: Cash App (Alternative)

**Similar to Venmo:**
- Fast setup
- Lower fees
- Less professional
- Weekly limits apply

**NOT RECOMMENDED for $500 transactions**

---

## RECOMMENDED SETUP: STRIPE PRIMARY + PAYPAL BACKUP

**Best Configuration:**

1. **Primary:** Stripe payment link
   - Professional appearance
   - Lower fees
   - Better tracking
   - Automatic receipts

2. **Backup:** PayPal invoicing
   - For buyers who prefer PayPal
   - Faster access to funds
   - Alternative if Stripe issues

**DM Response Template:**
```
Payment options:

1. Stripe (preferred): [Stripe link]
2. PayPal invoice: [Send to your email]

$500 one-time. Receipt sent after payment.
```

---

## PAYMENT LINK SECURITY

### Best Practices:

1. **Use HTTPS links only**
   - Stripe and PayPal are secure by default
   - Never use shortened links (bit.ly) - looks scammy

2. **Include Clear Description**
   - Product: "Genesis Pass - Founding Creator"
   - Amount: $500 USD
   - Terms: "No refunds. Closes 01/01/2026."

3. **Test Before Launch**
   - Process test payment
   - Verify receipt delivery
   - Check dashboard tracking
   - Confirm refund process (if needed)

4. **Keep Links Private**
   - Don't post publicly
   - Share only via DM
   - Track who receives link

---

## PAYMENT CONFIRMATION PROCESS

### After Payment Received:

1. **Verify Payment in Dashboard**
   - Check Stripe/PayPal dashboard
   - Confirm $500 received
   - Note buyer email

2. **Send Confirmation Message**
   ```
   Payment received. You're locked as Genesis Pass Founder #[X] of 20.

   Confirmation email sent to [their email].

   Full platform access rolls out Q1 2026. You'll be notified first.

   Welcome to the founders table.
   ```

3. **Record in Tracking Sheet**
   - Founder number (1-20)
   - Name
   - Email
   - Payment date
   - Payment method
   - Receipt ID

4. **Send Welcome Email (Optional)**
   ```
   Subject: Genesis Pass Confirmation - Founder #[X]

   [Name],

   Your Genesis Pass payment has been received.

   You are confirmed as Founder #[X] of 20.

   Receipt: [Stripe/PayPal receipt]

   Platform access launches Q1 2026. You'll be notified first.

   Thank you for funding infrastructure before visibility.

   - Nexus COS
   ```

---

## TRACKING PAYMENTS

### Spreadsheet Template:

```
| Founder # | Name | Email | Date | Amount | Method | Receipt ID | Status |
|-----------|------|-------|------|--------|--------|------------|--------|
| 1         | ...  | ...   | ...  | $500   | Stripe | ...        | PAID   |
| 2         | ...  | ...   | ...  | $500   | PayPal | ...        | PAID   |
...
```

### Daily Revenue Tracking:

```
Date       | Payments | Daily Total | Cumulative | Remaining
-----------|----------|-------------|------------|----------
Dec 26     | 2        | $1,000      | $1,000     | $9,000
Dec 27     | 3        | $1,500      | $2,500     | $7,500
Dec 28     | 4        | $2,000      | $4,500     | $5,500
...
```

---

## HANDLING PAYMENT ISSUES

### Issue 1: Payment Declined

**Cause:** Insufficient funds, card issues

**Response to Buyer:**
```
"Your payment was declined. Please try again or use alternative payment method.

Stripe: [link]
PayPal: [email for invoice]"
```

### Issue 2: Buyer Requests Refund

**Response:**
```
"Genesis Pass is non-refundable. This was stated before payment.

If there's a specific issue, please explain and I'll consider on a case-by-case basis."
```

**Decision:**
- Legitimate issue (payment error) → Consider refund
- Buyer's remorse → NO refund
- Document all refund decisions

### Issue 3: Duplicate Payment

**Response:**
```
"I see duplicate payment. Refunding the second transaction now.

You're confirmed as Founder #[X]. Thank you."
```

**Action:** Issue refund immediately

### Issue 4: Wrong Amount Sent

**Response:**
```
"Payment received for $[amount]. Genesis Pass is $500.

Please send remaining $[difference], or I can refund and you can resubmit correct amount."
```

---

## FEE CALCULATION

### Stripe Fees:

```
Sale: $500.00
Stripe Fee: $14.80 (2.9% + $0.30)
Your Net: $485.20

20 sales:
Gross: $10,000.00
Fees: $296.00
Net: $9,704.00
```

### PayPal Fees:

```
Sale: $500.00
PayPal Fee: $17.94 (3.49% + $0.49)
Your Net: $482.06

20 sales:
Gross: $10,000.00
Fees: $358.80
Net: $9,641.20
```

**Stripe saves ~$63 compared to PayPal**

---

## TAX CONSIDERATIONS

### Important:

1. **This is taxable income**
   - $10,000 will be reported to IRS
   - Set aside ~25-30% for taxes
   - Consult tax professional

2. **Business Structure**
   - Sole proprietor: Report on Schedule C
   - LLC/Corp: Report as business income

3. **Expense Deductions**
   - THIIO Developer costs ($497/month) = deductible
   - Platform fees (Stripe/PayPal) = deductible
   - Marketing costs = deductible

**Not tax advice. Consult professional.**

---

## FRAUD PREVENTION

### Red Flags:

1. **Unusual payment patterns**
   - Multiple payments from same card
   - International cards (if unexpected)
   - Large volume in short time

2. **Chargeback requests**
   - Buyer disputes payment
   - Claims "didn't authorize"
   - Stripe/PayPal investigates

### Protection:

1. **Clear Terms**
   - State "No refunds" before payment
   - Document all communication
   - Save DM screenshots

2. **Stripe/PayPal Protection**
   - Both offer seller protection
   - Provide proof of digital goods delivery
   - Respond quickly to disputes

3. **Documentation**
   - Save all DM conversations
   - Record confirmation messages
   - Track access granted dates

---

## CLOSING PAYMENT SYSTEM (Jan 1, 2026)

### At 11:59 PM:

1. **Disable Payment Links**
   - Deactivate Stripe payment link
   - Stop sending PayPal invoices
   - Update link destinations to "Closed" page (optional)

2. **Send Final Confirmations**
   - Email all 20 founders
   - Confirm their founder number
   - State access date (Q1 2026)

3. **Update Public Messaging**
   - Social posts: "Genesis is closed."
   - DM responses: "Closed 01/01/2026. No reopening."

4. **Financial Close**
   - Calculate final revenue
   - Document all transactions
   - Prepare for tax reporting

---

## BACKUP PAYMENT OPTIONS

### If Stripe/PayPal Issues:

**Option A: Wire Transfer (for large buyers)**
- Provide bank details securely
- Slower but reliable
- No fees

**Option B: Crypto (if appropriate)**
- USDC/USDT stablecoin
- Bitcoin/ETH (price volatility risk)
- Lower fees
- Requires wallet setup

**Option C: Zelle (US only)**
- Bank-to-bank transfer
- No fees
- Instant
- Requires phone/email registration

**NOT RECOMMENDED: Checks, money orders, cash**

---

## PRE-LAUNCH CHECKLIST

### Payment System Ready:

- [ ] Stripe account verified
- [ ] Payment link created and tested
- [ ] PayPal backup ready
- [ ] Receipt emails configured
- [ ] Tracking spreadsheet prepared
- [ ] Confirmation message templates ready
- [ ] Test payment processed successfully
- [ ] Dashboard notifications enabled
- [ ] Refund process understood
- [ ] Tax documentation system setup

**Status:** ✅ READY / ❌ NOT READY

---

## DAILY PAYMENT ROUTINE

### Morning (7-9 AM):
- [ ] Check payment dashboard
- [ ] Record new payments
- [ ] Send confirmation messages
- [ ] Update tracking sheet

### Midday (12-2 PM):
- [ ] Check pending payments
- [ ] Follow up on declined payments
- [ ] Send payment links to ready buyers

### Evening (8-10 PM):
- [ ] Final payment check
- [ ] Calculate daily revenue
- [ ] Update progress tracking
- [ ] Prepare tomorrow's payments

---

## CUSTOMER SUPPORT

### Common Questions:

**Q: "Is this secure?"**
A: "Yes. Payment processed through Stripe [or PayPal], which is bank-level security."

**Q: "Will you store my card?"**
A: "No. Stripe processes payment. I never see your card details."

**Q: "Can I pay in installments?"**
A: "No. $500 one-time payment only."

**Q: "Do you accept [other payment method]?"**
A: "Stripe or PayPal only. If you need alternative, DM me."

---

**STATUS:** ✅ PAYMENT SETUP GUIDE COMPLETE  
**PRIORITY:** CRITICAL - SETUP BEFORE DEC 26  
**OWNER:** TRAE SOLO
