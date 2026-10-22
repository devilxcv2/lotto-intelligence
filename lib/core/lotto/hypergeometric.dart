// lib/core/lotto/hypergeometric.dart

/// Coefficiente binomiale esatto. Dart usa interi a precisione arbitraria.
BigInt binomial(int n, int k) {
  if (k < 0 || n < 0 || k > n) return BigInt.zero;
  if (k == 0 || k == n) return BigInt.one;
  var kk = k;
  if (kk > n - kk) kk = n - kk;
  var result = BigInt.one;
  for (var i = 1; i <= kk; i++) {
    result = result * BigInt.from(n - kk + i) ~/ BigInt.from(i);
  }
  return result;
}

/// P(X = k) per un'estrazione uniforme di [drawSize] numeri da [population],
/// quando [successStates] numeri sono quelli "favorevoli".
double hypergeometricPmf({
  required int population,
  required int successStates,
  required int drawSize,
  required int observed,
}) {
  if (observed < 0 || observed > drawSize || observed > successStates) return 0;
  final other = drawSize - observed;
  if (other > population - successStates) return 0;
  final numerator = binomial(successStates, observed) * binomial(population - successStates, other);
  final denominator = binomial(population, drawSize);
  if (denominator == BigInt.zero) return 0;
  return numerator / denominator;
}

/// Probabilità che un numero specifico compaia in una cinquina equa.
const double singleNumberProbability = 5 / 90;

/// Valore atteso della somma di 5 numeri distinti uniformi da 1 a 90.
/// La linearità dell'attesa vale anche senza reinserimento.
const double expectedSumOfFive = 5 * (91 / 2);
