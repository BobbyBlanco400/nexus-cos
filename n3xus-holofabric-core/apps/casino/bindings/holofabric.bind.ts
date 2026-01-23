import { enforceLAW } from "@n3xus/law-gateway";
import { validateManifest } from "@n3xus/manifest-engine";

export async function bindCasinoScene(req: any) {
  enforceLAW(req);

  const scene = await validateManifest(req.scene);
  if (!scene) throw new Error("INVALID_SCENE");

  return {
    status: "BOUND",
    scene_id: scene.scene_id
  };
}
