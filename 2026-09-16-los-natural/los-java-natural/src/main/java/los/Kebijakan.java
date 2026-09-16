package los;

import java.math.BigDecimal;

/** Kebijakan bank beserta penyesuaian bunganya. Pilihannya tetap, jadi cukup enum. */
public enum Kebijakan {
    KONSERVATIF("0.5"),
    STANDAR("0.0"),
    AGRESIF("-0.5");

    private final BigDecimal penyesuaian;

    Kebijakan(String penyesuaian) {
        this.penyesuaian = new BigDecimal(penyesuaian);
    }

    public BigDecimal penyesuaian() {
        return penyesuaian;
    }
}
