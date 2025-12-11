export default function mapCustomer(obj) {
  return {
    officeId: 1,
    firstname: obj.first_name,
    lastname: obj.last_name,
    mobileNo: obj.phone,
    dateFormat: "dd MMMM yyyy",
    locale: "en",
    active: true
  };
}

export function mapLoan(obj) {
  return {
    clientId: obj.client_id,
    productId: obj.product_id,
    principal: obj.principal,
    loanTermFrequency: obj.term_months,
    numberOfRepayments: obj.term_months,
    loanTermFrequencyType: 2,
    amortizationType: 1,
    interestRatePerPeriod: obj.interest_rate,
    interestType: 0
  };
}
