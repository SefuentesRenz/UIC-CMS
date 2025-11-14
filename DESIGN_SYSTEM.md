# 🎨 UIC-CMS Professional Design System

## Overview
This document outlines the modern, professional design system applied to the University Clinic Management System (UIC-CMS).

---

## 🌈 Color Palette

### Primary Colors (Pink/Purple Theme)
```css
--primary-pink: #ec4899           /* Main brand color */
--primary-pink-dark: #db2777      /* Darker variant */
--primary-pink-darker: #be185d    /* Darkest variant */
--primary-pink-light: #f9a8d4     /* Light variant */

--secondary-purple: #d946ef       /* Secondary brand color */
--secondary-purple-dark: #c026d3  /* Darker variant */
```

### Functional Colors
```css
--success-green: #10b981
--success-green-dark: #059669

--warning-yellow: #f59e0b
--warning-orange: #f97316

--danger-red: #ef4444
--danger-red-dark: #dc2626
```

### Neutral Colors (Slate)
```css
--slate-50: #f8fafc    /* Lightest background */
--slate-100: #f1f5f9   /* Light backgrounds */
--slate-200: #e2e8f0   /* Borders */
--slate-300: #cbd5e1   
--slate-400: #94a3b8   /* Placeholders, icons */
--slate-500: #64748b   /* Secondary text */
--slate-600: #475569   /* Primary text */
--slate-700: #334155   
--slate-800: #1e293b   /* Headings */
--slate-900: #0f172a   /* Darkest text */
```

---

## 📏 Spacing System
```css
--spacing-xs: 4px
--spacing-sm: 8px
--spacing-md: 16px
--spacing-lg: 24px
--spacing-xl: 32px
--spacing-2xl: 48px
```

---

## 🔲 Border Radius
```css
--radius-sm: 6px    /* Small elements */
--radius-md: 10px   /* Buttons, inputs */
--radius-lg: 16px   /* Cards */
--radius-xl: 20px   /* Modals */
```

---

## 🎭 Shadows
```css
--shadow-sm: 0 1px 3px rgba(0, 0, 0, 0.08)
--shadow-md: 0 4px 12px rgba(0, 0, 0, 0.08)
--shadow-lg: 0 10px 40px rgba(0, 0, 0, 0.1)
--shadow-xl: 0 20px 60px rgba(0, 0, 0, 0.15)
```

---

## ⚡ Transitions
```css
--transition-fast: 0.15s cubic-bezier(0.4, 0, 0.2, 1)
--transition-base: 0.3s cubic-bezier(0.4, 0, 0.2, 1)
--transition-slow: 0.5s cubic-bezier(0.4, 0, 0.2, 1)
```

---

## 🎯 Component Patterns

### Primary Buttons
```css
background: linear-gradient(135deg, #ec4899, #d946ef);
color: white;
padding: 12px 24px;
border-radius: 10px;
box-shadow: 0 4px 12px rgba(236, 72, 153, 0.3);

/* Hover */
transform: translateY(-2px);
box-shadow: 0 6px 20px rgba(236, 72, 153, 0.4);
```

### Secondary Buttons (Gray)
```css
background: linear-gradient(135deg, #64748b, #475569);
color: white;
```

### Success Buttons (Green)
```css
background: linear-gradient(135deg, #10b981, #059669);
```

### Danger Buttons (Red)
```css
background: linear-gradient(135deg, #ef4444, #dc2626);
```

### Form Inputs
```css
padding: 13px 16px;
border: 2px solid #e2e8f0;
border-radius: 10px;
background: #f8fafc;

/* Focus State */
border-color: #ec4899;
background: white;
box-shadow: 0 0 0 4px rgba(236, 72, 153, 0.1);
```

### Modal Headers
```css
background: linear-gradient(135deg, #ec4899, #d946ef);
color: white;
padding: 24px 28px;
```

### Sidebar Active State
```css
background: linear-gradient(90deg, rgba(236, 72, 153, 0.1), transparent);
color: #ec4899;
border-left: 4px solid;
border-image: linear-gradient(180deg, #ec4899, #d946ef) 1;
```

---

## 📱 Responsive Breakpoints
```css
Mobile: max-width: 640px
Tablet: max-width: 768px
Desktop: max-width: 1024px
Large Desktop: max-width: 1280px
```

---

## ✅ Completed Components

### Authentication Pages
- ✅ **SignUp.vue** - Modern split-screen with pink/purple gradient
- ✅ **Login.vue** - Matching design with animations
- ✅ **Profile.vue** - Modal with gradient header

### Modal Components
- ✅ **AddPatient.vue** - Pink/purple theme applied
- ✅ **AddMedicine.vue** - Pink/purple theme applied
- ⏳ **ViewPatient.vue** - Needs color update
- ⏳ **AddTransaction.vue** - Needs color update
- ⏳ **EditTransaction.vue** - Needs color update
- ⏳ **AddStaff.vue** - Needs color update
- ⏳ **AddConsultation.vue** - Needs color update

### View Pages
- ⏳ **Dashboard.vue** - Needs professional update
- ⏳ **PatientRecord.vue** - Needs professional update
- ⏳ **Medicine.vue** - Needs professional update
- ⏳ **Transactions.vue** - Needs professional update
- ⏳ **ClinicStaffUsers.vue** - Needs professional update
- ⏳ **Consultations.vue** - Needs professional update

---

## 📁 File Structure
```
src/
├── assets/
│   └── dashboard-styles.css      # Global design system
├── components/
│   ├── Login.vue                 # ✅ Updated
│   ├── SignUp.vue                # ✅ Updated
│   ├── Profile.vue               # ✅ Updated
│   ├── AddPatient.vue            # ✅ Updated
│   ├── AddMedicine.vue           # ✅ Updated
│   ├── ViewPatient.vue           # ⏳ Pending
│   ├── AddTransaction.vue        # ⏳ Pending
│   ├── EditTransaction.vue       # ⏳ Pending
│   ├── AddStaff.vue              # ⏳ Pending
│   └── AddConsultation.vue       # ⏳ Pending
├── views/
│   ├── Dashboard.vue             # ⏳ Pending
│   ├── PatientRecord.vue         # ⏳ Pending
│   ├── Medicine.vue              # ⏳ Pending
│   ├── Transactions.vue          # ⏳ Pending
│   ├── ClinicStaffUsers.vue      # ⏳ Pending
│   └── Consultations.vue         # ⏳ Pending
└── router/
    └── index.js                  # Routes configuration
```

---

## 🎯 Design Principles

### 1. **Professional & Clean**
- No clutter, focused on content
- Proper whitespace and breathing room
- Clear visual hierarchy

### 2. **University-Appropriate**
- Professional color scheme (pink/purple)
- Trustworthy and modern aesthetic
- Healthcare-friendly design

### 3. **Consistent & Cohesive**
- Same patterns across all components
- Uniform spacing and sizing
- Predictable interactions

### 4. **Accessible & Responsive**
- Proper contrast ratios
- Mobile-friendly layouts
- Keyboard navigation support

### 5. **Smooth & Delightful**
- Subtle animations and transitions
- Hover and focus states
- Professional microinteractions

---

## 🚀 Usage Examples

### Using Global Styles
Import in your component:
```vue
<style>
@import '@/assets/dashboard-styles.css';
</style>
```

### Custom Button
```vue
<button class="btn-primary">
  Add Patient
</button>
```

### Modal Header
```vue
<div class="modal-header">
  <h2 class="modal-title">Add Patient</h2>
  <p class="modal-subtitle">Register new patient</p>
</div>
```

---

## 📝 Notes

- All colors use CSS custom properties for easy theming
- Transitions use cubic-bezier for smooth, natural motion
- Shadows create depth without being overwhelming
- Border radius values create modern, friendly aesthetic
- Pink/purple gradient creates distinctive brand identity

---

**Last Updated:** October 17, 2025  
**Design System Version:** 1.0  
**Status:** In Progress - Modals and Views pending updates
