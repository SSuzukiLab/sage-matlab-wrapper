# SageWrapper for MATLAB

`SageWrapper` is a MATLAB class that provides a streamlined interface to the [SageMath](https://www.sagemath.org/) symbolic computation environment via Python integration. It enables MATLAB users to execute Sage commands, evaluate symbolic expressions, and import specific Sage modules directly within the MATLAB environment.

---

## Features

- Launches and connects to a Sage-enabled Python environment via `pyenv` only once at initialization
- Allows execution of Sage (or Python) code using `exec`
- Provides persistent Sage namespace throughout the MATLAB session

---

## Requirements

- A compatible Python version for MATLAB (see [Python Compatibility](https://jp.mathworks.com/support/requirements/python-compatibility.html))
- SageMath installed with an accessible Python interface (via Conda or native install)
- A `SagePythonPath.txt` file containing the path to the Sage-enabled Python interpreter

**Example path for macOS M1 with SageMath 10.6:**
```
/Applications/SageMath-10-6.app/Contents/Frameworks/Sage.framework/Versions/Current/venv/bin/python3
```

> ✅ Tested with: macOS M1, SageMath 10.6, Python 3.12, MATLAB R2025a

---

## Usage

### 1. Access Singleton Instance

```matlab
SW = SageWrapper.H;
```

> ❗ Do not use `SageWrapper()` constructor directly.

### 2. Execute a Knot Example and Export Image

```matlab
SW = SageWrapper.H;
SW.exec("W = Knots()");
SW.exec("K = W.from_table(3, 1)");
gc = SW.exec("K.pd_code()");
SW.exec(sprintf("K.save_image('%s/test.png')", pwd));
```
This uses the Knots() interface in SageMath to load and analyze known knots (like 3_1), extract combinatorial data (PD code), and save visual representations. All operations are executed in Sage but scripted through MATLAB.


---

## Notes

- Only one Python process is allowed per MATLAB session (`pyenv` is global)
- Avoid calling `terminate(pyenv)` unless necessary; it will invalidate all current Python handles
- Ensure `SagePythonPath.txt` contains a valid and working Python path for Sage

warningを消す機能を追加してもいいかも