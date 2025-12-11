const fs = require('fs');
const path = require('path');

function generateDiagram() {
  const diagram = `graph TD
    A[PUABO BLAC / Personal & SBL] --> B[PUABO Core Adapter]
    C[Nexus Fleet Financing] --> B
    B --> D[Fineract CE]
    B --> E[Smart Contract Engine]
    E --> F[Blockchain / MusicChain]
    B --> G[PUABO AI Risk & KYC]
    D --> H[Accounts, Loans, Collateral]
    E --> H
`;
  
  const docsPath = path.join(__dirname, '../../../../docs/system-diagram.mmd');
  fs.writeFileSync(docsPath, diagram);
  console.log("System diagram generated at", docsPath);
}

module.exports = { generateDiagram };
