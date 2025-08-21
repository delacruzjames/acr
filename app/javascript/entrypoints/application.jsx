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
    const clear = async () => setCart(await j("POST", "/cart/clear"));

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

            <h2 style={{ marginTop: 32 }}>Cart</h2>
            <table width="100%">
                <thead>
                <tr>
                    <th align="left">Code</th>
                    <th>Qty</th>
                    <th align="right">Unit (€)</th>
                    <th align="right">Line (€)</th>
                </tr>
                </thead>
                <tbody>
                {cart.items.map((it) => {
                    const lineTotal = it.line_total ?? (Number(it.quantity) * Number(it.unit_price)); // NEW
                    return (
                        <tr key={it.code}>
                            <td>{it.code}</td>
                            <td align="center">{it.quantity}</td>
                            <td align="right">{Number(it.unit_price).toFixed(2)}</td>
                            <td align="right">{Number(lineTotal).toFixed(2)}</td>
                        </tr>
                    );
                })}
                </tbody>

            </table>
            <div style={{display: "flex", justifyContent: "space-between", marginTop: 12}}>
                <button onClick={clear}>Clear</button>
                <strong style={{fontSize: 18}}>Total: €{Number(cart.total).toFixed(2)}</strong>
            </div>
        </div>
    );
}

document.addEventListener("DOMContentLoaded", () => {
    const el = document.getElementById("root");
    if (el) createRoot(el).render(<App />);
});
