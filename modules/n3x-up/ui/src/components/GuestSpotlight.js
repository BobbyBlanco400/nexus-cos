import React from "react";

export const GuestSpotlight = ({ guestName, segmentTime }) => (
  <div className="guest-spotlight">
    <h2>{guestName}</h2>
    <p>Segment Time: {segmentTime} minutes</p>
  </div>
);

