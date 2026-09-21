package los;

/** Kebijakan bank beserta penyesuaian bunganya. Di Haskell ini data BankPolicy. */
public enum BankPolicy {
    CONSERVATIVE(0.5), STANDARD(0.0), AGGRESSIVE(-0.5);

    private final double penyesuaian;

    BankPolicy(double penyesuaian) {
        this.penyesuaian = penyesuaian;
    }

    public double penyesuaian() {
        return penyesuaian;
    }
}
