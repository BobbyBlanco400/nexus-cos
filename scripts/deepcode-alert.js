(async () => {
  const fetch = (await import('node-fetch')).default;

  const alert = {
    tool: { name: 'deepcode-code-scanning-analysis' },
    severity: 'high',
    most_recent_instance: {
      location: { path: 'studioone-lite/index.js' }
    },
    rule: { description: 'Potential injection vulnerability' },
    html_url: 'https://github.com/BobbyBlanco400/nexus-cos/security/code-scanning'
  };

  const payload = {
    text: `[DeepCode Alert] ${alert.tool.name} flagged a ${alert.severity.toUpperCase()} issue in *${alert.most_recent_instance.location.path}*.\n> ${alert.rule.description}\n🔗 ${alert.html_url}`
  };

  try {
    const res = await fetch(process.env.SLACK_WEBHOOK_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload)
    });
    console.log(`Slack alert sent: ${res.status}`);
  } catch (err) {
    console.error('Slack alert failed:', err);
  }
})();
