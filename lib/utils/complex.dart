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
  
  Complex add(Complex other) {
    return Complex(real + other.real, imaginary + other.imaginary);
  }
  
  Complex subtract(Complex other) {
    return Complex(real - other.real, imaginary - other.imaginary);
  }
  
  Complex multiply(Complex other) {
    return Complex(
      real * other.real - imaginary * other.imaginary,
      real * other.imaginary + imaginary * other.real,
    );
  }
  
  Complex divide(Complex other) {
    double denominator = other.real * other.real + other.imaginary * other.imaginary;
    if (denominator.abs() < 1e-10) {
      // Avoid division by near-zero values
      throw Exception('Division by near-zero complex number');
    }
    return Complex(
      (real * other.real + imaginary * other.imaginary) / denominator,
      (imaginary * other.real - real * other.imaginary) / denominator,
    );
  }
  
  double abs() {
    return magnitude;
  }
  
  Complex operator -() {
    return Complex(-real, -imaginary);
  }
  
  Complex operator +(Complex other) {
    return add(other);
  }
  
  Complex operator -(Complex other) {
    return subtract(other);
  }
  
  Complex operator *(Complex other) {
    return multiply(other);
  }
  
  Complex operator /(Complex other) {
    return divide(other);
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