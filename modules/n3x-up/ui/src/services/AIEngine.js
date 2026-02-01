export class AIEngine {
  constructor() {
    this.dynamicPrompts = [];
  }

  queuePrompt(time, type, message) {
    this.dynamicPrompts.push({ time, type, message });
  }

  triggerPrompts(currentTime) {
    return this.dynamicPrompts.filter((p) => p.time === currentTime);
  }
}

