import axios from "axios";
import { useState } from "react";
import "./App.css";

function App() {
  const [file, setFile] = useState(null);
  const [preview, setPreview] = useState(null);
  const [result, setResult] = useState(null);
  const [loading, setLoading] = useState(false);

  const handleFileChange = (e) => {
    const selected = e.target.files[0];
    setFile(selected);
    setPreview(URL.createObjectURL(selected));
    setResult(null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!file) {
      alert("Please upload an image first!");
      return;
    }

    setLoading(true);
    const formData = new FormData();
    formData.append("file", file);

    try {
      const backendUrl = process.env.REACT_APP_BACKEND_URL;
      console.log("Using backend URL:");
      console.log(backendUrl);
      const res = await axios.post(`${backendUrl}/predict`, formData, {
        headers: { "Content-Type": "multipart/form-data" },
      });
      setResult(res.data);
    } catch (err) {
      console.error(err);
      alert("Error connecting to backend");
    } finally {
      setLoading(false);
    }
  };

  const getBinImage = (binName) => {
    if (!binName) return null;
    const lower = binName.toLowerCase();
    if (lower.includes("bio")) return "images/bioabfall.jpg";
    if (lower.includes("paper")) return "images/paper.jpg";
    if (lower.includes("yellow")) return "images/yellow_bin.jpg";
    return null;
  };

  return (
    <div className="app-wrapper">

      {/* Main Content */}
      <div className="content">
        <h1 className="title">♻️ Waste Classifier 🇩🇪</h1>
        <p className="subtitle">
          Upload an image to quickly identify the waste type and recommended bin.
        </p>

        <div className="main-grid">
          {/* Upload Section */}
          <div className="card">
            <h2 className="card-title">Upload an Image</h2>
            <form onSubmit={handleSubmit}>
              <label className="file-drop">
                <input
                  type="file"
                  accept="image/*"
                  onChange={handleFileChange}
                  className="file-input"
                />
                {preview ? (
                  <>
                    <img src={preview} alt="Preview" className="preview-image" />
                    <button
                      type="button"
                      className="btn-cancel-overlay"
                      onClick={(e) => {
                        e.preventDefault();
                        setFile(null);
                        setPreview(null);
                        setResult(null);
                      }}
                    >
                      ✖
                    </button>
                  </>
                ) : (
                  <div className="drop-text">
                    <p>📁 Drag or click to upload</p>
                    <span className="hint">Accepted: JPG, PNG</span>
                  </div>
                )}
              </label>

              <button
                type="submit"
                disabled={loading}
                className={`btn-submit ${loading ? "loading" : ""}`}
              >
                {loading ? "Predicting..." : "Predict"}
              </button>
            </form>
          </div>

          {/* Result Section */}
          <div className="card">
            <h2 className="card-title">Prediction Result</h2>
            {result ? (
              <div className="result-panel">
                <div className="result-item">
                  <span>Class</span>
                  <strong>{result.class}</strong>
                </div>
                <div className="result-item">
                  <span>Confidence</span>
                  <strong>{(result.confidence * 100).toFixed(2)}%</strong>
                </div>
                <div className="result-item">
                  <span>Recommended Bin</span>
                  <strong>{result.bin} 🗑️</strong>
                </div>

                {getBinImage(result.bin) && (
                  <div className="bin-preview">
                    <img
                      src={getBinImage(result.bin)}
                      alt={result.bin}
                      className="bin-image"
                    />
                  </div>
                )}
              </div>
            ) : (
              <div className="placeholder">
                Upload an image to see prediction results here ✨
              </div>
            )}
          </div>
        </div>
      </div>

      <footer className="footer">
        Built by Sahil Sharma using FastAPI & React.js | © 2025 Waste Classifier
      </footer>
    </div>
  );
}

export default App;
