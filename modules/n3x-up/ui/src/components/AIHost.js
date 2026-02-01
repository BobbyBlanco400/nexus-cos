export class AIHost {
  constructor() {
    this.prompts = [];
  }

  addPrompt(time, text) {
    this.prompts.push({ time, text });
  }

  getPrompt(currentTime) {
    const eligible = this.prompts.filter((p) => p.time <= currentTime);
    if (eligible.length === 0) {
      return null;
    }
    return eligible[eligible.length - 1].text;
  }
}

