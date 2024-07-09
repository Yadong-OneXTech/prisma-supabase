import { createClient } from '@supabase/supabase-js'

// Create a single supabase client for interacting with your database
const supabase = createClient('https://kcwgemzqwuojwhunzxkw.supabase.co', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imtjd2dlbXpxd3VvandodW56eGt3Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjAwODMzODcsImV4cCI6MjAzNTY1OTM4N30.PZV_ChygMm-0fI2gGE2hE2xk3PMHHxphUqMYvGAI2mk')

const main = async () => {
	// Sign in user
	const { data, error } = await supabase.auth.signInWithPassword({
		email: 'miniboy918@dcbin.com',
		password: 'miniboy918@dcbin.com'
	})

	// console.log(data)

	const { data: foo, error: bar } = await supabase.from('user').update({ workspace_id: 1 }).eq('id', data.user?.id).select('*')

	console.log('id: ', data.user?.id)
	console.log('foo: ', foo)
	console.log('bar: ', bar)
}

(async () => {
	await main()
})()

