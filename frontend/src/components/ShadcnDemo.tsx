import { Button } from "@/components/ui/button"

export function ShadcnDemo() {
  return (
    <div className="p-4 space-y-4">
      <div className="border rounded-lg p-6 bg-card">
        <h3 className="text-lg font-semibold mb-4">shadcn/ui Setup Verified ✓</h3>
        <p className="text-muted-foreground mb-4">
          The shadcn/ui infrastructure is properly configured and ready to receive components from v0.dev.
        </p>
        <div className="flex gap-2 flex-wrap">
          <Button>Default Button</Button>
          <Button variant="secondary">Secondary</Button>
          <Button variant="outline">Outline</Button>
          <Button variant="ghost">Ghost</Button>
          <Button variant="destructive">Destructive</Button>
        </div>
      </div>
    </div>
  )
}
