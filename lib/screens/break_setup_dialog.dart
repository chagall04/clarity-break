// lib/screens/break_setup_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For HapticFeedback and TextInputFormatters

// Defines the return type for the dialog, containing user input.
class BreakSetupResult {
  final String userWhy;
  final int duration; // Selected break duration in days.
  BreakSetupResult({required this.userWhy, required this.duration});
}

// Shows a dialog to get the user's reason AND desired break duration.
Future<BreakSetupResult?> showBreakSetupDialog(BuildContext context) async {
  final theme = Theme.of(context); // Access theme data for styling.
  final whyController = TextEditingController(); // Controller for the reason text field.
  final customDurationController = TextEditingController(); // Controller for custom duration input.

  int? selectedPresetDuration = 28; // Default preset is 28 days (nullable).
  int? customDuration; // Stores validated custom duration (nullable).
  bool isCustomSelected = false; // Flag for custom input state.

  final List<int> durationOptions = [7, 14, 21, 28]; // Preset duration choices.

  // Use showDialog which returns a Future that completes when the dialog is popped.
  return showDialog<BreakSetupResult>(
    context: context,
    barrierDismissible: false, // User must tap a button to close.
    builder: (BuildContext dialogContext) {
      // Use StatefulBuilder to manage the selectedDuration/custom state locally within the dialog.
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          // Determine the final duration to display/save, defaulting if needed.
          int finalDuration = (isCustomSelected ? customDuration : selectedPresetDuration) ?? 28;

          return AlertDialog( // Standard Material dialog widget.
            title: Text(
              'Start Your Clarity Break', // Dialog title.
              style: theme.textTheme.headlineSmall,
            ),
            // Use SingleChildScrollView to prevent overflow.
            content: SingleChildScrollView(
              child: ListBody( // Arrange children vertically.
                children: <Widget>[
                  // --- Reason Input Section ---
                  Text( // Prompt text for the reason input.
                    'First, why are you taking this break? Seeing your reason helps stay motivated!',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16), // Vertical spacing.
                  TextField( // Text input field for the user's "Why".
                    controller: whyController,
                    autofocus: true, // Automatically focus this field.
                    decoration: const InputDecoration(
                      labelText: 'My Reason ("My Why")', // Field label.
                      hintText: 'e.g., Reset tolerance, improve focus...', // Placeholder text.
                    ),
                    textInputAction: TextInputAction.next, // Suggest 'next' action on keyboard.
                    maxLines: 3, // Allow multiple lines.
                    textCapitalization: TextCapitalization.sentences, // Capitalize sentences.
                  ),
                  const SizedBox(height: 24), // Vertical spacing.

                  // --- Duration Selection Section ---
                  Text( // Prompt text for duration selection.
                    'Choose your break duration:',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8), // Vertical spacing.
                  Wrap( // Arrange duration chips responsively.
                      spacing: 8.0, // Horizontal space between chips.
                      runSpacing: 4.0, // Vertical space between chip rows.
                      children: [
                        // --- Preset Duration Chips ---
                        ...durationOptions.map((duration) {
                          bool isSelected = !isCustomSelected && selectedPresetDuration == duration;
                          bool isRecommended = duration >= 21;

                          // Style the chip differently if it's the selected 28-day option.
                          Color? selectedChipColor = isSelected
                              ? (duration == 28 ? theme.colorScheme.primaryContainer : theme.chipTheme.selectedColor)
                              : theme.chipTheme.backgroundColor;
                          TextStyle? selectedChipLabelStyle = isSelected
                              ? theme.chipTheme.secondaryLabelStyle?.copyWith(
                              color: duration == 28 ? theme.colorScheme.onPrimaryContainer : theme.chipTheme.secondaryLabelStyle?.color
                          )
                              : theme.chipTheme.labelStyle;

                          return ChoiceChip(
                            label: Text('$duration Days'),
                            selected: isSelected,
                            selectedColor: selectedChipColor,
                            labelStyle: selectedChipLabelStyle,
                            tooltip: isRecommended ? 'Recommended for significant reset' : null,
                            visualDensity: VisualDensity.compact, // Make chips smaller
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onSelected: (bool selected) {
                              if (selected) {
                                setStateDialog(() { // Update dialog state
                                  isCustomSelected = false;
                                  selectedPresetDuration = duration;
                                  customDurationController.clear();
                                  customDuration = null;
                                });
                              }
                            },
                          );
                        }).toList(),

                        // --- "Custom" Choice Chip ---
                        ChoiceChip(
                          label: const Text('Custom'),
                          selected: isCustomSelected,
                          selectedColor: theme.chipTheme.selectedColor,
                          labelStyle: isCustomSelected ? theme.chipTheme.secondaryLabelStyle : theme.chipTheme.labelStyle,
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          onSelected: (bool selected) {
                            setStateDialog(() { // Update dialog state
                              isCustomSelected = selected;
                              selectedPresetDuration = null; // Deselect presets
                            });
                          },
                        ),
                      ]
                  ),
                  const SizedBox(height: 8),

                  // --- Custom Duration Input Field (Conditional) ---
                  AnimatedContainer( // Animate show/hide
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    // Height is 0 when hidden, non-zero when shown
                    height: isCustomSelected ? 75.0 : 0.0,
                    // Use Opacity and Offstage for better handling of focus/layout when hidden
                    child: Opacity(
                      opacity: isCustomSelected ? 1.0 : 0.0,
                      child: Offstage(
                        offstage: !isCustomSelected,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: TextField( // Text field for custom number of days
                            controller: customDurationController,
                            keyboardType: TextInputType.numberWithOptions(signed: false, decimal: false), // Number keyboard
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                            decoration: InputDecoration(
                                labelText: 'Enter Days', // Keep label short
                                hintText: '1-99', // Guide user on range
                                counterText: '', // Hide the default character counter
                                isDense: true, // Reduce field height
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10) // Adjust padding
                            ),
                            maxLength: 2, // Limit to 2 digits
                            // Validate input as user types
                            onChanged: (value) {
                              setStateDialog(() {
                                int? parsedValue = int.tryParse(value);
                                // Basic validation: ensure it's within a reasonable range (e.g., 1 to 99)
                                if (parsedValue != null && parsedValue >= 1 && parsedValue <= 99) {
                                  customDuration = parsedValue;
                                } else {
                                  customDuration = null; // Invalidate if empty or out of range
                                }
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  ),

                  // --- Helper text emphasizing recommended duration ---
                  Text(
                    'Note: 21-28 days is often recommended for a more complete tolerance reset.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            // --- Dialog Action Buttons ---
            actions: <Widget>[
              TextButton( // Cancel button
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop(); // Close the dialog, returning null
                },
              ),
              FilledButton( // Confirmation button
                style: FilledButton.styleFrom( // Inherit primary style from theme
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                ),
                // Disable button if custom duration is selected but invalid
                onPressed: (isCustomSelected && customDuration == null) ? null : () {
                  final whyText = whyController.text.trim();
                  // Check if reason is provided and duration is valid
                  if (whyText.isNotEmpty && finalDuration > 0) {
                    // Provide haptic feedback for successful start confirmation
                    HapticFeedback.mediumImpact();
                    // Pop the dialog and return the BreakSetupResult object
                    Navigator.of(dialogContext).pop(
                        BreakSetupResult(userWhy: whyText, duration: finalDuration)
                    );
                  } else {
                    // Determine appropriate error message
                    String errorMsg = 'Please enter your reason.';
                    if(whyText.isNotEmpty && isCustomSelected && customDuration == null) {
                      errorMsg = 'Please enter a valid custom duration (1-99 days).';
                    } else if (whyText.isNotEmpty && !isCustomSelected && selectedPresetDuration == null) {
                      errorMsg = 'Please select a duration.'; // Should not normally happen
                    }
                    // Show error message if inputs are invalid
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMsg), duration: const Duration(seconds: 2), behavior: SnackBarBehavior.floating),
                    );
                  }
                },
                // Button text dynamically shows the final selected duration
                child: Text('Begin $finalDuration-Day Break'),
              ),
            ],
          );
        },
      );
    },
  );
} // End of showBreakSetupDialog