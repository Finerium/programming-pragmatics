import org.scalatest.flatspec.AnyFlatSpec

class LogFactTest extends AnyFlatSpec:

  import LogFact.*

  "logFact" should "bernilai 0 untuk 0 dan 1" in {
    assert(logFact(0) == 0.0)
    assert(logFact(1) == 0.0)
  }

  it should "sama dengan log dari 5! = 120" in {
    assert(math.abs(logFact(5) - math.log(120)) < 1e-12)
  }

  it should "cocok dengan versi fold dan lgamma Breeze untuk n = 10000" in {
    assert(math.abs(logFact(10000) - logFactFold(10000)) < 1e-6)
    assert(math.abs(logFact(10000) - breeze.numerics.lgamma(10001.0)) < 1e-6)
  }
