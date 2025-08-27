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

function currency(n) { return Number(n).toFixed(2); }

function App() {
    const [products, setProducts] = useState([]);
    const [cart, setCart] = useState({ items: [], total: 0 });

    useEffect(() => {
        fetch("/products").then(r => r.json()).then(setProducts);
        j("GET", "/carts").then(setCart);
    }, []);

    const add = async (code) => {
        const updated = await j("POST", "/carts/add_item", { code });
        setCart(updated);
    };

    const clear = async () => {
        const updated = await j("POST", "/carts/clear");
        setCart(updated);
    };

    return (
        <div style={{ maxWidth: 820, margin: "40px auto", fontFamily: "Inter, system-ui" }}>
            <h1>Amenitiz Cash Register</h1>

            <section style={{ marginBottom: 24 }}>
                <h2>Products</h2>
                <ul>
                    {products.map(p => (
                        <li key={p.id} style={{ display: "flex", gap: 12, alignItems: "center" }}>
                            <code style={{ width: 56 }}>{p.code}</code>
                            <span style={{ flex: 1 }}>{p.name}</span>
                            <span>€{currency(p.price)}</span>
                            <button onClick={() => add(p.code)}>Add</button>
                        </li>
                    ))}
                </ul>
            </section>

            <section>
                <h2>Cart</h2>
                <button onClick={clear}>Clear cart</button>
                <table width="100%" cellPadding="6" style={{ marginTop: 12, borderCollapse: "collapse" }}>
                    <thead>
                    <tr>
                        <th align="left">Code</th>
                        <th align="left">Name</th>
                        <th align="right">Qty</th>
                        <th align="right">Unit</th>
                        <th align="right">Line</th>
                    </tr>
                    </thead>
                    <tbody>
                    {cart.items.map(it => {
                        const unit = Number(it.unit_price);
                        const effective = Number(it.effective_unit_price ?? unit);
                        const discounted = !Number.isNaN(effective) && effective !== unit;

                        // Prefer server-computed line_total (handles BOGOF exact 3.11)
                        const line = Number(
                            it.line_total ?? (effective * Number(it.quantity))
                        );

                        return (
                            <tr key={it.code}>
                                <td><code>{it.code}</code></td>
                                <td>{it.name}</td>
                                <td align="right">{it.quantity}</td>
                                <td align="right">
                                    {discounted ? (
                                        <>
              <span style={{ textDecoration: "line-through", opacity: 0.6, marginRight: 6 }}>
                €{Number(unit).toFixed(2)}
              </span>
                                            <strong>€{Number(effective).toFixed(2)}</strong>
                                        </>
                                    ) : (
                                        <>€{Number(unit).toFixed(2)}</>
                                    )}
                                </td>
                                <td align="right"><strong>€{Number(line).toFixed(2)}</strong></td>
                            </tr>
                        );
                    })}
                    </tbody>

                    <tfoot>
                    <tr>
                        <td colSpan={4} align="right"><strong>Total</strong></td>
                        <td align="right"><strong>€{currency(cart.total)}</strong></td>
                    </tr>
                    </tfoot>
                </table>
            </section>
        </div>
    );
}

document.addEventListener("DOMContentLoaded", () => {
    const el = document.getElementById("root");
    if (el) createRoot(el).render(<App />);
});
