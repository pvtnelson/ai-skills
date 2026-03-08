# JSON Schemas Reference

## Table of Contents
- [evals.json](#evalsjson)
- [eval_metadata.json](#eval_metadatajson)
- [grading.json](#gradingjson)
- [timing.json](#timingjson)
- [benchmark.json](#benchmarkjson)
- [feedback.json](#feedbackjson)

## evals.json

Test cases for a skill. Stored in `<skill-dir>/evals/evals.json`.

```json
{
  "skill_name": "my-skill",
  "evals": [
    {
      "id": 0,
      "query": "The user prompt to test with",
      "expectations": [
        "Expected behavior or output (graded by grader agent)",
        "Another expected outcome"
      ]
    }
  ]
}
```

## eval_metadata.json

Per-eval metadata, stored in `<workspace>/iteration-N/eval-N/eval_metadata.json`.

```json
{
  "eval_id": 0,
  "query": "The test prompt",
  "expectations": [
    "Expected behavior 1",
    "Expected behavior 2"
  ]
}
```

## grading.json

Grader agent output, stored in `<workspace>/iteration-N/eval-N/<config>/run-N/grading.json`.

```json
{
  "expectations": [
    {
      "text": "The expectation string",
      "passed": true,
      "evidence": "Evidence from transcript supporting PASS/FAIL"
    }
  ],
  "summary": "Overall assessment of the run",
  "claims": [
    {
      "type": "factual|process|quality",
      "claim": "A claim extracted from the output",
      "verified": true,
      "evidence": "Supporting evidence"
    }
  ],
  "eval_feedback": [
    "Suggestions for improving the eval assertions"
  ]
}
```

## timing.json

Execution timing data, stored alongside grading.json.

```json
{
  "total_duration_seconds": 12.5,
  "total_tokens": 4200
}
```

## benchmark.json

Aggregated benchmark output from `scripts/aggregate_benchmark.py`.

```json
{
  "metadata": {
    "skill_name": "my-skill",
    "executor_model": "claude-opus-4-6",
    "timestamp": "2026-03-07T12:00:00Z",
    "evals_run": [0, 1, 2],
    "runs_per_configuration": 2
  },
  "run_summary": {
    "with_skill": {
      "pass_rate": { "mean": 0.85, "std": 0.1 },
      "time_seconds": { "mean": 15.2, "std": 3.1 },
      "tokens": { "mean": 5000, "std": 800 }
    },
    "baseline": {
      "pass_rate": { "mean": 0.60, "std": 0.15 },
      "time_seconds": { "mean": 20.1, "std": 4.5 },
      "tokens": { "mean": 6200, "std": 1100 }
    },
    "delta": {
      "pass_rate": "+25.0%",
      "time_seconds": "-24.4%",
      "tokens": "-19.4%"
    }
  },
  "runs": [],
  "notes": []
}
```

## feedback.json

User feedback after reviewing results via eval-viewer. Stored in `<workspace>/iteration-N/feedback.json`.

```json
{
  "overall": "pass|fail|mixed",
  "comments": "Free-form user feedback",
  "per_eval": [
    {
      "eval_id": 0,
      "verdict": "pass|fail",
      "note": "Optional note"
    }
  ]
}
```
