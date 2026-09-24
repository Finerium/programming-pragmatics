/*
LogFact.scala
Latihan sbt dari Scala hands-on fp-ssc-course: cetak log-factorial 10000.
Jalankan dari folder ini: sbt run  (atau sbt "run 20" untuk n lain)
*/

import scala.annotation.tailrec

object LogFact:

  // rekursi ekor, jadi aman untuk n besar tanpa stack overflow
  @tailrec
  def logFact(n: Int, acc: Double = 0.0): Double =
    if n <= 1 then acc else logFact(n - 1, math.log(n) + acc)

  // versi fold, tanpa rekursi yang ditulis sendiri
  def logFactFold(n: Int): Double =
    (2 to n).foldLeft(0.0)((acc, k) => acc + math.log(k))

  def main(args: Array[String]): Unit =
    val n = args.headOption.map(_.toInt).getOrElse(10000)
    println(s"log($n!) dengan rekursi ekor = ${logFact(n)}")
    println(s"log($n!) dengan foldLeft     = ${logFactFold(n)}")
    println(s"lgamma($n + 1) dari Breeze   = ${breeze.numerics.lgamma(n + 1.0)}")
