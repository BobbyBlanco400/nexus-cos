module.exports = async function approveLoan(loan) {
  const riskThreshold = 70;
  if (loan.riskScore >= riskThreshold && loan.amount <= 100000) {
    return { status: "approved", auto: true };
  } else {
    return { status: "manual_review" };
  }
}
