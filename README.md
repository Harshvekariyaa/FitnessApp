
/// ExerciseScreen
///
/// Accepts TWO different raw-map shapes and normalises them internally.
/// Pass [isAiWorkout: true] when launching from AiWorkoutDetails so the
/// correct API endpoint is called (updateAiExerciseProgress vs
/// updateExerciseProgress).
///
/// ── REGULAR WORKOUT (original shape) ────────────────────────────────────
/// {
///   "exercise_order"       : int,
///   "is_completed"         : int,
///   "sets_completed"       : int,
///   "reps_completed"       : int,
///   "exercise_duration_sec": int,   ← may be 0; real value is nested
///   "exercise": {
///     "exercise_id"             : int,
///     "exercise_name"           : String,
///     "exercise_gif_full_url"   : String,
///     "exercise_description"    : String,
///     "exercise_sets"           : int,
///     "exercise_reps"           : int,
///     "exercise_duration_second": int
///   }
/// }
///
/// ── AI WORKOUT (flat shape) ──────────────────────────────────────────────
/// {
///   "exercise_id"            : int,
///   "exercise_name"          : String,
///   "exercise_gif_full_url"  : String,
///   "exercise_description"   : String,
///   "exercise_sets"          : int,
///   "exercise_reps"          : int,
///   "exercise_duration_sec"  : int,
///   "exercise_order"         : int,
///   "exercise_xp"            : int,
///   "exercise_calories_burn" : double,
///   "is_completed"           : int,
///   "sets_completed"         : int,
///   "reps_completed"         : int,
/// }