
const double _MinNumber = 0.008;

double clampMin(double v) {
  if (v < _MinNumber && v > -_MinNumber) {
    if (v >= 0) {
      v = _MinNumber;
    } else {
      v = -_MinNumber;
    }
  }
  return v;
}
double mapNumber(double number, double oldRangeMin, double oldRangeMax,
    double newRangeMin, double newRangeMax) {
  // Clamps the number to the old range
  double clampedNumber = number.clamp(oldRangeMin, oldRangeMax);
  return (((clampedNumber - oldRangeMin) * (newRangeMax - newRangeMin)) /
      (oldRangeMax - oldRangeMin)) + newRangeMin;
}