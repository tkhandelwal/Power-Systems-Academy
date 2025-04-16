# Power Systems Academy

A comprehensive mobile application for power engineering education, exam preparation, and calculations.

## Overview

Power Systems Academy is designed to help electrical power engineers prepare for the PE Power exam and provide useful tools for day-to-day power engineering calculations. The app features interactive calculators, study materials, practice questions, and educational content to make learning and working with power engineering concepts easier and more accessible.

## Key Features

### Power Engineering Calculators

The app includes a wide range of power engineering calculators to help with common power system calculations:

- **Power Triangle Calculator**: Calculate relationships between active, reactive, and apparent power
- **Three-Phase Power Calculator**: Calculate three-phase system parameters
- **Power Factor Correction Calculator**: Determine capacitor requirements for improving power factor
- **Transformer Sizing Calculator**: Size transformers for various applications
- **Voltage Drop Calculator**: Calculate voltage drop in conductors and check compliance
- **Short Circuit Calculator**: Analyze fault currents and equipment ratings
- **Load Flow Calculator**: Perform power flow analysis of electrical networks
- **Motor Starting Calculator**: Analyze voltage dips and starting requirements for motors
- **Protection Coordination Calculator**: Verify proper coordination of protective devices

Each calculator includes educational content explaining the underlying concepts, relevant formulas, and practical applications. Calculators also provide visual representations of the results to enhance understanding.

### Unified Calculator Hub

A central calculator hub provides easy access to all calculation tools with:

- Quick access to recently used calculators
- Categorization by application area
- Educational content and guidance
- Ability to save and recall calculation settings
- Consistent UI across all calculator modules

### Study Materials

Comprehensive study materials for the PE Power exam:

- Topic-organized study guides
- Practice questions with detailed explanations
- Flashcards for key concepts and formulas
- NEC code reference guide
- Power engineering formula reference
- Exam preparation tips and strategies

### Personalized Study Planner

Create a customized study plan:

- Set your exam date and track progress
- Prioritize topics based on exam blueprint
- Allocate study time efficiently
- Monitor progress with analytics
- Schedule practice exams

### Community Features

Connect with other power engineering professionals:

- Discussion forums for exam preparation
- Study groups for collaborative learning
- Q&A section for technical questions
- News updates on power engineering topics

## Technical Implementation

The app is built with Flutter for cross-platform compatibility and features:

- Consistent, modern UI design
- Dark mode support
- Offline functionality for core calculators
- Save and export calculation results
- Responsive layout for different devices

### Architecture

The app follows a modular architecture:

- **Base Calculator Widget**: Provides a consistent UI template for all calculators
- **Educational Content Widget**: Standardized component for delivering educational content
- **Calculator Service**: Manages calculator usage history and saved calculations
- **Calculator Provider**: Handles calculator state management across the app
- **Calculator Utilities**: Common calculation functions and utility methods

### Core Components

- **Calculator Hub Screen**: Central navigation point for all calculators
- **Base Calculator Widget**: Reusable widget for consistent calculator UI
- **Educational Content Widget**: Standardized educational component
- **Calculator Utilities**: Helper functions for common calculations

### Extension Points

The application is designed to be easily extendable with new calculators:

1. Create a new calculator screen that uses the `BaseCalculatorScreen` widget
2. Add the calculator to the `CalculatorProvider` available calculators list
3. Add a route in the `main.dart` file
4. Update the calculator hub to include the new calculator

## Getting Started

### Prerequisites

- Flutter SDK (2.10 or later)
- Dart SDK (2.16 or later)
- Android Studio or VS Code with Flutter extensions

### Installation

1. Clone the repository:

```bash
git clone https://github.com/yourusername/powersystemsacademy.git
```

2. Navigate to the project directory:

```bash
cd powersystemsacademy
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the app:

```bash
flutter run
```

## Contributing

Contributions are welcome! If you'd like to add a new calculator or improve existing ones:

1. Fork the repository
2. Create a feature branch
3. Add your changes
4. Submit a pull request

## License

Copyright © [2025] [Tanuj Khandelwal/QuantaGrid]. All Rights Reserved
