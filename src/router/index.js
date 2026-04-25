import { createRouter, createWebHistory } from 'vue-router'
import { supabase } from '@/lib/Supabase.js'
import LoginPage from '../components/Login.vue'
import SignUpPage from '../components/SignUp.vue'
import DashboardPage from '../views/Dashboard.vue'
import StudentHomePage from '../views/StudentHome.vue'
import PatientRecordPage from '../views/PatientRecord.vue'
import MedicinePage from '../views/Medicine.vue'
import TransactionsPage from '../views/Transactions.vue'
import ClinicStaffUsersPage from '../views/ClinicStaffUsers.vue'
import ConsultationsPage from '../views/Consultations.vue'


const routes = [
  {
    path: '/',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'Login',
    component: LoginPage,
    meta: { public: true }
  },
  {
    path: '/signup',
    name: 'SignUp',
    component: SignUpPage,
    meta: { public: true }
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: DashboardPage,
    meta: { requiresAuth: true, allowDemo: true }
  },
  {
    path: '/student-home',
    name: 'StudentHome',
    component: StudentHomePage,
    meta: { requiresAuth: true }
  },
  {
    path: '/patient-record',
    name: 'PatientRecord',
    component: PatientRecordPage,
    meta: { requiresAuth: true, allowDemo: true }
  },
  {
    path: '/medicine',
    name: 'Medicine',
    component: MedicinePage,
    meta: { requiresAuth: true, allowDemo: true }
  },
  {
    path: '/transactions',
    name: 'Transactions',
    component: TransactionsPage,
    meta: { requiresAuth: true, allowDemo: true }
  },
  {
    path: '/consultations',
    name: 'Consultations',
    component: ConsultationsPage,
    meta: { requiresAuth: true, allowDemo: true }
  },
  {
    path: '/staff-users',
    name: 'StaffUsers',
    component: ClinicStaffUsersPage,
    meta: { requiresAuth: true, allowDemo: true }
  }
]

const router = createRouter({
  // Vite exposes env via import.meta.env
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

router.beforeEach(async (to) => {
  const isDemoFromQuery = to.query.demo === '1'

  if (isDemoFromQuery) {
    sessionStorage.setItem('uic_demo_mode', '1')
  } else if (to.path === '/login') {
    sessionStorage.removeItem('uic_demo_mode')
  }

  const isDemoMode = sessionStorage.getItem('uic_demo_mode') === '1'

  if (to.meta.public) {
    return true
  }

  if (to.meta.allowDemo && isDemoMode) {
    return true
  }

  if (!to.meta.requiresAuth) {
    return true
  }

  const { data: { session }, error } = await supabase.auth.getSession()

  if (error) {
    return { path: '/login' }
  }

  if (!session) {
    return { path: '/login' }
  }

  return true
})

export default router
