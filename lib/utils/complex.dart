// lib/utils/complex.dart
import 'dart:math';

class Complex {
  final double real;
  final double imaginary;
  
  const Complex(this.real, this.imaginary);
  
  factory Complex.polar(double magnitude, double angle) {
    return Complex(
      magnitude * cos(angle),
      magnitude * sin(angle),
    );
  }
  
  double get magnitude => sqrt(real * real + imaginary * imaginary);
  double get angle => atan2(imaginary, real);
  
  Complex get conjugate => Complex(real, -imaginary);
  
  Complex operator +(Complex other) {
    return Complex(real + other.real, imaginary + other.imaginary);
  }
  
  Complex operator -(Complex other) {
    return Complex(real - other.real, imaginary - other.imaginary);
  }
  
  Complex operator *(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }
  
  Complex operator /(Complex other) {
    double denominator = other.real * other.real + other.imaginary * other.imaginary;
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denominator,
      (imaginary * other.real - real * other.imaginary) / denominator,
    );
  }
  
  double abs() {
    return magnitude;
  }
  
  @override
  String toString() {
    if (imaginary >= 0) {
      return '$real + ${imaginary}i';
    } else {
      return '$real - ${-imaginary}i';
    }
  }
}