import { useState } from 'react'
import { createRoot } from 'react-dom/client'
import './styles.css'

const digest = '0x8c4a...f915'

function Arrow() { return <span aria-hidden="true">↗</span> }

function App() {
  const [checked, setChecked] = useState(false)
  const [address, setAddress] = useState('0x71C...09d2')

  return (
    <main>
      <nav>
        <a className="brand" href="#top"><i>p</i> ProofPass</a>
        <div className="nav-links"><a href="#how">How it works</a><a href="#registry">Registry</a><a href="https://github.com" target="_blank">GitHub <Arrow /></a></div>
        <button className="connect" onClick={() => setAddress(address === '0x71C...09d2' ? '0x93F...A042' : '0x71C...09d2')}>{address}</button>
      </nav>

      <section className="hero" id="top">
        <p className="eyebrow">A public record for private proofs</p>
        <h1>Credentials that<br /><em>carry their trust.</em></h1>
        <p className="intro">ProofPass gives organizations a minimal, verifiable way to issue credentials—without placing personal documents on-chain.</p>
        <div className="actions"><a className="button primary" href="#registry">Verify a credential <Arrow /></a><a className="button ghost" href="#how">See the protocol ↓</a></div>
        <div className="hero-rule"><span>Built for the next proof</span><span>Ethereum compatible · Open by default</span></div>
      </section>

      <section className="feature-grid" id="how">
        <article><b>01</b><h2>Issue with intent.</h2><p>Authorized issuers anchor a document digest to a wallet, with an optional metadata reference.</p></article>
        <article className="ink"><b>02</b><h2>Verify in seconds.</h2><p>A digest answers one simple question: is this credential current and issued by someone trusted?</p></article>
        <article><b>03</b><h2>Revoke with clarity.</h2><p>The issuing organization can retire a credential while preserving a transparent audit trail.</p></article>
      </section>

      <section className="registry" id="registry">
        <div className="registry-copy"><p className="eyebrow">Live registry interface</p><h2>One hash.<br />A clear answer.</h2><p>Paste a credential digest to check its on-chain status. The credential itself stays off-chain.</p><div className="stat"><strong>0x</strong><span>Only a cryptographic<br />fingerprint is public.</span></div></div>
        <div className="terminal">
          <div className="terminal-top"><span></span><span></span><span></span><small>proofpass / verify</small></div>
          <label htmlFor="digest">CREDENTIAL HASH</label>
          <div className="input-row"><input id="digest" value={digest} readOnly /><button onClick={() => setChecked(true)}>Check</button></div>
          <div className={`result ${checked ? 'show' : ''}`}>
            <div className="result-head"><span className="dot">✓</span><strong>Credential valid</strong><small>issued 18 Apr 2025</small></div>
            <dl><div><dt>Subject</dt><dd>0x71C…09d2</dd></div><div><dt>Issuer</dt><dd>Northstar Academy</dd></div><div><dt>Record</dt><dd>ipfs://bafy…9Qz</dd></div></dl>
          </div>
          {!checked && <p className="hint">Try the sample credential above.</p>}
        </div>
      </section>

      <section className="manifesto"><p>Proof should be <em>portable, private,</em> and plain to verify.</p><a href="https://github.com" target="_blank">Read the source <Arrow /></a></section>
      <footer><a className="brand" href="#top"><i>p</i> ProofPass</a><span>Credential registry protocol · 2025</span><span>Built on Ethereum</span></footer>
    </main>
  )
}

createRoot(document.getElementById('root')).render(<App />)
