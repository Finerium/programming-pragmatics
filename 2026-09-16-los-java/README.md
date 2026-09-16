# los-java — Loan Originating System versi Java OO

Permintaan Pak Joe di grup, 16 September 2026: dibuatkan versi Java OO dari `los-haskell`
dan `los-prolog`. Domainnya sama persis, yaitu proses pengajuan kredit (LOS), dan urutan
bagiannya dibuat sama dengan `app/Main.hs` serta `main.pl` supaya gampang dibandingkan.

Dikerjakan dengan OpenJDK 25 (`java -version`), tanpa Maven atau Gradle, tanpa library luar,
jadi cukup `javac` dan `java` saja.

## Peta konsep: Haskell → Prolog → Java OO

| Konsep | Haskell | Prolog | Java OO |
|---|---|---|---|
| Tipe data domain | `data LoanApplication` | compound term `loan_app/7` | `record LoanApplication` |
| Immutability | record update `app { annualRate = ... }` | term baru tiap perubahan | record + method `withRate`, `withScore` |
| ADT + pattern matching | `data LoanDecision = Approved \| ...` | `approved/2`, `rejected/1` | `sealed interface` + `record` + `switch` pattern |
| Fungsi sebagai nilai | `type Rule = LoanApplication -> Bool` | goal sebagai data, `call/2` | `@FunctionalInterface Rule`, lambda |
| Higher-order function | `all (\r -> r app) rules` | `maplist/2`, `include/3` | `Stream.allMatch`, `filter` |
| Kegagalan bertipe | `Either String a` | `ok(X)` / `error(Msg)` | `sealed interface Result<T>` (`Ok` / `Err`) |
| Komposisi fungsi | `notify . decide . adjust` | rantai predikat lewat variabel antara | `Function.andThen` |
| Reader (config) | `ReaderT BankConfig` | argumen config dioper terus | config disuntik lewat constructor |
| State | `StateT BankState` | pasangan `StateIn, StateOut` | `BankState` immutable, dioper masuk dan dikembalikan |
| Except | `ExceptT String` | `catch/throw` | `Result.Err`, state hanya ikut di jalur sukses |
| Type class + default method | `class Auditable` | multifile `audit_entry/3` | `interface Auditable` + `default severity()` |
| Existential type | `AnyAuditable` | list heterogen native | `List<Auditable>` (polimorfisme subtipe) |
| Property-based testing | QuickCheck | plunit + generator | `Spec.java`, generator acak sendiri |

## Yang lebih mudah di Java OO

- **List campur tidak butuh trik khusus.** Di Haskell perlu existential type `AnyAuditable`,
  di Java cukup `List<Auditable>` karena subtipe otomatis cocok dengan tipe interface-nya.
- **Config tidak perlu dioper ke mana-mana.** Reader monad diganti constructor injection:
  `new UnderwritingService(config)`, lalu semua method internal tinggal membaca field-nya.
- **Struktur berkas langsung kelihatan.** Satu tipe satu berkas, jadi mudah dicari.

## Yang lebih ribet di Java OO

- **Tipe bawaan tidak bisa ditambahi interface.** Haskell bisa bikin `instance Auditable String`,
  Java tidak, jadi string dibungkus dulu jadi `record Note`.
- **Immutability harus dijaga manual.** Record membantu, tapi `withRate`, `withScore`, dan
  `BankState.log` tetap ditulis tangan, sedangkan Haskell punya sintaks record update.
- **Tidak ada monad transformer.** Reader, State, dan Except digabung manual di
  `UnderwritingService`, jadi urutannya jelas tetapi tidak bisa dipakai ulang seperti tumpukan monad.

## Struktur

```
los-java/
├── src/los/          15 berkas sumber, satu tipe satu berkas
├── kelas/            hasil kompilasi (dibuat ulang oleh javac)
├── hasil/            keluaran teks Main dan Spec
├── tangkapan/        screenshot terminal
└── README.md
```

| Berkas | Isi |
|---|---|
| `LoanApplication`, `BankConfig`, `BankState`, `BankPolicy` | tipe data domain |
| `LoanDecision` | sealed interface + tiga record keputusan |
| `Rule`, `Rules` | aturan underwriting sebagai nilai |
| `Calculations` | DTI dan cicilan bulanan |
| `Result` | padanan Either |
| `Pipeline` | adjust, decide, notify, validate, process |
| `UnderwritingService` | Reader + State + Except versi OO |
| `Auditable`, `AuditSeverity`, `AuditTrail`, `Note` | audit trail lewat interface |
| `Main` | demo end-to-end |
| `Spec` | property-based test tanpa library |

## Cara menjalankan

```bash
javac -d kelas src/los/*.java
java -cp kelas los.Main      # demo end-to-end
java -cp kelas los.Spec      # property-based test

# mode interaktif, padanan GHCi dan swipl
jshell --class-path kelas
jshell> import los.*
jshell> Calculations.calculateDti(3000000, 12000000)
jshell> Pipeline.fullPipeline(new LoanApplication("Budi", 200000000, 0, 24, 680, 3000000, 12000000))
jshell> /exit
```

## Catatan hasil

Keluaran `los.Main` sama urutan dan isinya dengan versi Haskell dan Prolog, angkanya juga sama
(DTI 0.25, cicilan Rp9.045.458, rate akhir 7,75%, sisa kuota Rp800 juta).

`los.Spec` sengaja dibuat meniru QuickCheck, termasuk cara membuang kasus yang tidak relevan.
Hasilnya memperlihatkan masalah yang sama dengan versi Haskell: property
`validateRejectsNonPositivePrincipal` menyerah karena generatornya tidak pernah menghasilkan
principal yang nol atau negatif, jadi property itu praktis tidak pernah teruji. Artinya masalahnya
ada di generator, bukan di bahasanya.
