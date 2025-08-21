import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";

function App() {
    const [products, setProducts] = useState([]);
    useEffect(() => {
        fetch("/products").then(r => r.json()).then(setProducts);
    }, []);
    return (
        <div style={{ maxWidth: 720, margin: "40px auto", fontFamily: "Inter, system-ui" }}>
            <h1>Products</h1>
            <div>Loaded: {products.length}</div>
            <ul>
                {products.map(p => (
                    <li key={p.id}>{p.code} — {p.name} (€{Number(p.price).toFixed(2)})</li>
                ))}
            </ul>
        </div>
    );
}

document.addEventListener("DOMContentLoaded", () => {
    const el = document.getElementById("root");
    if (el) createRoot(el).render(<App />);
});
