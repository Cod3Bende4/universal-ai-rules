# 06-FRONTEND.md
# PURPOSE: Component design, state management, accessibility, responsiveness, and frontend security
# LOAD WHEN: Building UI components, pages, layouts, or any browser-rendered code

---

## Component Design Rules

### Component Structure
- [ ] One component per file — single responsibility for files
- [ ] Component name matches file name — `UserProfile.tsx` exports `UserProfile`
- [ ] Props are typed explicitly — TypeScript interface or PropTypes
- [ ] Default values for optional props — prevent undefined behavior
- [ ] No business logic in components — delegate to hooks, services, or stores
- [ ] Max 150 lines per component file — split if larger

### Component Hierarchy
- [ ] Presentational components have no side effects — pure rendering only
- [ ] Container components handle data fetching and state — pass down via props
- [ ] Shared components live in `components/shared/` — reusable across features
- [ ] Feature components live in `features/{name}/components/` — scoped to feature
- [ ] Layout components live in `components/layout/` — headers, footers, sidebars

### Prop Rules
- [ ] Max 7 props per component — if more, refactor or use composition
- [ ] No prop drilling deeper than 2 levels — use context or state management
- [ ] Boolean props use affirmative names — `isVisible` not `isNotHidden`
- [ ] Callback props prefixed with `on` — `onClick`, `onSubmit`, `onChange`
- [ ] Children over render props — simpler API for most cases
- [ ] Destructure props at the component boundary — explicit about what's used

---

## State Management Rules

### State Location Decision Tree
```
Is the state used by only one component?
└─ YES → useState (local state)

Is the state shared by parent and 1-2 children?
└─ YES → Lift state to parent, pass via props

Is the state used across many unrelated components?
└─ YES → Use context or state management library

Is the state server data (fetched from API)?
└─ YES → Use a data fetching library (React Query, SWR, RTK Query)

Is the state URL-derived (pagination, filters)?
└─ YES → Use URL search params
```

### Rules
- [ ] Never duplicate server state in local state — use a query cache library
- [ ] URL is state for navigation, pagination, and filters — use search params
- [ ] Form state stays local until submission — don't sync every keystroke to global store
- [ ] Loading and error states are always handled — never leave a component in limbo
- [ ] Optimistic updates for fast UX — revert on failure
- [ ] Stale data is better than no data — show cached while fetching fresh

⚠️ WARNING: Global state is not a database. If you're putting everything in global state, you're probably doing it wrong. Most state should be local or server-cached.

---

## Accessibility (a11y) Rules

### Mandatory — Non-Negotiable
- [ ] All images have alt text — descriptive or empty (`alt=""`) for decorative
- [ ] All form inputs have labels — `<label>` element or `aria-label`
- [ ] All interactive elements are keyboard accessible — tab, enter, escape
- [ ] Color is never the ONLY indicator — add icons, text, or patterns
- [ ] Focus management on route changes — focus moves to main content
- [ ] Error messages linked to form fields — `aria-describedby`
- [ ] Page has a single `<h1>` — proper heading hierarchy (h1 → h2 → h3)
- [ ] Semantic HTML over div soup — `<nav>`, `<main>`, `<article>`, `<button>`

### Testing
- [ ] Run axe or lighthouse accessibility audit — zero violations
- [ ] Test with keyboard only — complete all critical flows without a mouse
- [ ] Test with screen reader — VoiceOver (Mac), NVDA (Windows)
- [ ] Ensure minimum contrast ratio 4.5:1 for text — WCAG AA standard
- [ ] Ensure tap targets are ≥44x44px on mobile — big enough for fingers

✅ DEFAULT: Use native HTML elements before reaching for ARIA. A `<button>` is more accessible than a `<div role="button">`.

---

## Responsive Design Rules

### Breakpoints
| Name | Min Width | Target Devices |
|---|---|---|
| Mobile | 0px | Phones |
| Tablet | 768px | Tablets, small laptops |
| Desktop | 1024px | Laptops, desktops |
| Wide | 1440px | Large monitors |

### Rules
- [ ] Mobile-first approach — write base styles for mobile, add complexity for larger screens
- [ ] Test all pages at all breakpoints — not just desktop
- [ ] No horizontal scroll on any breakpoint — content fits the viewport
- [ ] Touch targets ≥44x44px on mobile — finger-friendly
- [ ] Text readable without zoom on mobile — minimum 16px body text
- [ ] Images are responsive — `max-width: 100%`, use `srcset` for performance
- [ ] Tables have horizontal scroll containers on mobile — don't break layout
- [ ] Modals and overlays work on mobile — dismissible, scrollable, properly sized

---

## Performance Rules

### Loading
- [ ] Lazy load routes/pages — don't load all pages upfront
- [ ] Lazy load images below the fold — use `loading="lazy"`
- [ ] Lazy load heavy components — code-split with dynamic imports
- [ ] Minimize bundle size — tree-shake, avoid large libraries for small features
- [ ] Preload critical resources — fonts, above-the-fold images
- [ ] Use optimized image formats (WebP, AVIF) — smaller than PNG/JPEG

### Rendering
- [ ] Memoize expensive computations — `useMemo`, `useCallback` for reference stability
- [ ] Virtualize long lists (100+ items) — render only visible items
- [ ] Debounce user input handlers — search, resize, scroll
- [ ] Avoid layout thrashing — batch DOM reads, then batch writes
- [ ] No animations on elements that trigger layout — use transform and opacity only

### Targets
| Metric | Target |
|---|---|
| First Contentful Paint | < 1.5 seconds |
| Largest Contentful Paint | < 2.5 seconds |
| Cumulative Layout Shift | < 0.1 |
| First Input Delay | < 100ms |
| Total Blocking Time | < 200ms |
| Bundle size (gzipped) | < 200KB initial load |

---

## Form Handling Rules

- [ ] Validate on blur for each field — immediate feedback
- [ ] Validate all fields on submit — catch anything missed
- [ ] Show inline error messages per field — not just a top-level error
- [ ] Preserve form state on validation error — don't clear user input
- [ ] Disable submit button during submission — prevent double submit
- [ ] Show loading indicator during submission — user knows it's working
- [ ] Handle server validation errors — map API errors to form fields
- [ ] Confirm destructive actions — "Are you sure?" for deletes

---

## 🛑 STOP: Frontend Gate

Before submitting frontend code:

1. [ ] Are all components under 150 lines?
2. [ ] Is state in the correct location (local, URL, context, or server cache)?
3. [ ] Do all images have alt text?
4. [ ] Are all form inputs labeled?
5. [ ] Does the page work on mobile (tested at 375px width)?
6. [ ] Are loading and error states handled?
7. [ ] Is the accessibility audit passing with zero violations?

---

## Security Checkpoint

- [ ] User input is sanitized before rendering — prevent XSS
- [ ] No `dangerouslySetInnerHTML` without sanitization — XSS vector
- [ ] Auth tokens stored in HTTP-only cookies — not localStorage
- [ ] Sensitive data not stored in localStorage/sessionStorage — client-side is insecure
- [ ] CSRF protection on all state-changing requests — use tokens or SameSite cookies
- [ ] No secrets in frontend code — API keys, secrets are server-side only
- [ ] CSP headers configured — prevent inline script injection
- [ ] All external links have `rel="noopener noreferrer"` — prevent tabnapping
