package los;

import java.util.function.Function;

/**
 * Padanan Either di Haskell: hasil yang bisa sukses (Ok) atau gagal dengan pesan (Err).
 * Kegagalan jadi bagian dari tipe kembalian, bukan exception yang bisa lupa ditangani.
 */
public sealed interface Result<T> permits Result.Ok, Result.Err {

    record Ok<T>(T value) implements Result<T> {
    }

    record Err<T>(String message) implements Result<T> {
    }

    static <T> Result<T> ok(T nilai) {
        return new Ok<>(nilai);
    }

    static <T> Result<T> err(String pesan) {
        return new Err<>(pesan);
    }

    default boolean berhasil() {
        return this instanceof Ok<T>;
    }

    default <R> Result<R> map(Function<T, R> f) {
        return switch (this) {
            case Ok<T> ok -> Result.ok(f.apply(ok.value()));
            case Err<T> err -> Result.err(err.message());
        };
    }

    default <R> Result<R> flatMap(Function<T, Result<R>> f) {
        return switch (this) {
            case Ok<T> ok -> f.apply(ok.value());
            case Err<T> err -> Result.err(err.message());
        };
    }
}
