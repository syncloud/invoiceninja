import { test } from '../fixtures'
import { shoot } from '../helpers/screenshot'
import {
  addCompany,
  createClient,
  createInvoice,
  createProduct,
  login,
  nameCompany,
  openPayments,
  openSettings,
} from '../helpers/invoiceninja'

const run = Date.now().toString(36)
const client = `Client ${run}`
const product = `Product-${run}`

test('device user signs in and bills a client', async ({ page }) => {
  await test.step('login', async () => {
    await login(page)
    await shoot(page, 'login')
  })

  await test.step('name the default company', async () => {
    await nameCompany(page, 'Test Company')
    await shoot(page, 'main')
  })

  await test.step('settings', async () => {
    await openSettings(page)
    await shoot(page, 'settings')
  })

  await test.step('new client', async () => {
    await createClient(page, client)
    await shoot(page, 'client')
  })

  await test.step('new product', async () => {
    await createProduct(page, product, '100')
    await shoot(page, 'product')
  })

  await test.step('payments', async () => {
    await openPayments(page)
    await shoot(page, 'payments')
  })

  await test.step('new invoice', async () => {
    await createInvoice(page, client, product)
    await shoot(page, 'invoice')
  })

  await test.step('new company', async () => {
    await addCompany(page, `Second Company ${run}`)
    await shoot(page, 'new-company')
  })
})
