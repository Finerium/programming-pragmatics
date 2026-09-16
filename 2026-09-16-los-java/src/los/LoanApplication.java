package los;

/**
 * Data pengajuan pinjaman. Record Java itu immutable, sama seperti record di Haskell:
 * tidak ada setter, perubahan dilakukan dengan membuat salinan (method with...).
 */
public record LoanApplication(String applicantName, double principal, double annualRate, int termMonths,
                              int creditScore, double monthlyDebt, double monthlyIncome) implements Auditable {

    public LoanApplication withRate(double rate) {
        return new LoanApplication(applicantName, principal, rate, termMonths, creditScore, monthlyDebt, monthlyIncome);
    }

    public LoanApplication withScore(int score) {
        return new LoanApplication(applicantName, principal, annualRate, termMonths, score, monthlyDebt, monthlyIncome);
    }

    public LoanApplication withPrincipal(double jumlah) {
        return new LoanApplication(applicantName, jumlah, annualRate, termMonths, creditScore, monthlyDebt, monthlyIncome);
    }

    public LoanApplication withName(String nama) {
        return new LoanApplication(nama, principal, annualRate, termMonths, creditScore, monthlyDebt, monthlyIncome);
    }

    /** Nama pemohon disamarkan di satu tempat saja, jadi tidak ada pemanggil yang lupa menyamarkannya. */
    @Override
    public String toString() {
        return "LoanApplication{applicant=" + samarkan(applicantName)
                + ", principal=" + Fmt.rupiah(principal)
                + ", score=" + creditScore + "}";
    }

    private static String samarkan(String nama) {
        return nama.length() >= 3 ? nama.charAt(0) + "***" : nama;
    }

    @Override
    public String auditEntry() {
        return "APPLICATION | applicant=" + applicantName
                + " | principal=" + Fmt.rupiah(principal)
                + " | score=" + creditScore;
    }
}
