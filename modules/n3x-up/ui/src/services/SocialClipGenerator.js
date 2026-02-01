export class SocialClipGenerator {
  constructor() {
    this.clips = [];
  }

  addClip(time, type, content) {
    this.clips.push({ time, type, content });
  }

  exportClips() {
    console.log("Exporting social media highlight clips");
  }
}

