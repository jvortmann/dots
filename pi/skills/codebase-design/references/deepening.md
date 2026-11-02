# Deepening

How to merge a cluster of shallow modules into a deep one without losing
safety. The words are those of `SKILL.md`: module, interface, seam, adapter.

## Dependency categories

Sort the dependencies of the cluster first. The category sets how you test the deep
module across its seam.

### 1. In-process

Pure computation and state in memory, with no I/O. You can always deepen it.
Merge the modules and test through the new interface. You need no adapter.

### 2. Local stand-in

The dependency has a stand-in that runs locally, such as PGLite for Postgres
or an in-memory file system. You can deepen it when the stand-in exists. The
test suite runs the stand-in. The seam stays internal, so the external
interface shows no port.

### 3. Remote but owned

Your own services across a network, such as microservices and internal APIs.
Define a **port** at the seam. The deep module owns the logic, and the
transport enters as an **adapter**. Tests use an in-memory adapter.
Production uses an HTTP, gRPC or queue adapter.

Give advice in this shape. Define a port at the seam. Write an HTTP adapter
for production and an in-memory adapter for tests. The logic then lives in
one deep module, although the system runs across a network.

### 4. True external

Third-party services that you do not control, such as Stripe or Twilio. The
deep module takes the dependency as an injected port. Tests give it a mock
adapter.

## Seam discipline

- **No port without two adapters.** One adapter means a hypothetical seam.
  Add a port only when you can justify two adapters, usually production
  and test. A seam with one adapter is only indirection.
- **Keep internal seams out of the interface.** A deep module can have seams
  private to its implementation, used by its own tests. Do not expose them
  because a test uses them.

## Tests: replace, do not layer

- Delete the old unit tests of the shallow modules once tests at the new
  interface exist. They are waste after that point.
- Write the new tests at the interface of the deep module. The interface is
  the test surface.
- Assert observable outcomes through the interface. Do not assert internal
  state.
- A test must survive an internal refactor, because it describes behavior and
  not implementation. A test that changes when the implementation changes
  tests past the interface.
