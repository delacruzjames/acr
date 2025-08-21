import React, { useEffect, useState } from "react";
import { createRoot } from "react-dom/client";

const csrfToken = () =>
    document.querySelector('meta[name="csrf-token"]')?.content || "";

async function j(method, url, body) {
    const res = await fetch(url, {
        method,
        headers: {
            "Content-Type": "application/json",
            "X-CSRF-Token": csrfToken(),
        },
        credentials: "same-origin",
        body: body ? JSON.stringify(body) : undefined,
    });
    if (!res.ok) throw new Error(await res.text());
    return res.json();
}

function App() {
    const [products, setProducts] = useState([]);
    const [cart, setCart] = useState({ items: [], total: 0 });

    useEffect(() => {
        (async () => {
            const [p, c] = await Promise.all([j("GET", "/products"), j("GET", "/cart")]);
            setProducts(p);
            setCart(c);
        })().catch(console.error);
    }, []);

    const add = async (code) => setCart(await j("POST", "/cart/add_item", { code }));
    return (
        <div style={{ maxWidth: 720, margin: "40px auto", fontFamily: "Inter, system-ui" }}>
            <h1>Products</h1>
            <ul>
                {products.map((p) => (
                    <li key={p.id}>
                        {p.code} — {p.name} (€{Number(p.price).toFixed(2)}){" "}
                        <button onClick={() => add(p.code)}>Add</button>
                    </li>
                ))}
            </ul>
        </div>
    );
}

document.addEventListener("DOMContentLoaded", () => {
    const el = document.getElementById("root");
    if (el) createRoot(el).render(<App />);
});
