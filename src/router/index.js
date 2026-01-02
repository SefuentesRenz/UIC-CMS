import { createRouter, createWebHistory } from 'vue-router'
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
    component: LoginPage
  },
  {
    path: '/signup',
    name: 'SignUp',
    component: SignUpPage
  },
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: DashboardPage
  },
  {
    path: '/student-home',
    name: 'StudentHome',
    component: StudentHomePage
  },
  {
    path: '/patient-record',
    name: 'PatientRecord',
    component: PatientRecordPage
  },
  {
    path: '/medicine',
    name: 'Medicine',
    component: MedicinePage
  },
  {
    path: '/transactions',
    name: 'Transactions',
    component: TransactionsPage
  },
  {
    path: '/consultations',
    name: 'Consultations',
    component: ConsultationsPage
  },
  {
    path: '/staff-users',
    name: 'StaffUsers',
    component: ClinicStaffUsersPage
  }
]

const router = createRouter({
  // Vite exposes env via import.meta.env
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router
