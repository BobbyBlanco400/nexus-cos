export class SpatialIntegration {
  constructor() {
    this.guests = [];
    this.visuals = [];
  }

  addGuest(name, avatar) {
    this.guests.push({ name, avatar });
  }

  addVisualOverlay(overlay) {
    this.visuals.push(overlay);
  }

  renderScene() {
    const guestNames = this.guests.map((g) => g.name).join(", ");
    const overlayCount = this.visuals.length;
    console.log(
      `Rendering spatial environment with guests: ${guestNames} and ${overlayCount} overlays`
    );
  }
}

