import { createClient } from 'npm:@supabase/supabase-js@2'
import { JWT } from 'npm:google-auth-library@9'
import serviceAccount from '../serviceAccountKey.json' with { type: 'json' }
import * as postgres from 'https://deno.land/x/postgres@v0.17.0/mod.ts'

interface Notification {
  id: string
  profile_id: string | null
  is_for_all: boolean
  notification_type: string
  arguments: Record<string, unknown>
  created_at: string
}

interface WebhookPayload {
  type: 'INSERT'
  table: string
  record: Notification
  schema: 'public'
}

const databaseUrl = Deno.env.get('SUPABASE_DB_URL')!

const pool = new postgres.Pool(databaseUrl, 3, true)

const supabase = createClient(
  Deno.env.get('SUPABASE_URL')!,
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
)

const getUserNickname = async (reactionId: number): Promise<string | undefined> => {
  const connection = await pool.connect()

  try {
    const result = await connection.queryObject`
      SELECT profiles.nickname FROM reactions
        INNER JOIN profiles
        ON reactions.profile_id = profiles.id
      WHERE reactions.id = ${reactionId}
    `
    if (result.rows.length > 0) {
      return result.rows[0]?.nickname
    } else {
      return undefined
    }
  } catch(error) {
    console.error(`failed to fetch profile entity from db. ${error}`)
    return undefined
  }
}

const getQuestionTitle = async (questionId: number): Promise<string | undefined> => {
  const connection = await pool.connect()

  try {
    const result = await connection.queryObject`SELECT * FROM questions WHERE id = ${questionId}`
    if (result.rows.length > 0) {
      return result.rows[0]?.content
    } else {
      return undefined
    }
  } catch(error) {
    console.error(`failed to fetch question entity from db. ${error}`)
    return undefined
  }
}

Deno.serve(async (req) => {
  const payload: WebhookPayload = await req.json()
  const notif = payload.record

  const getMessageTitle = (n: Notification): string => {
    switch (n.notification_type) {
      case 'NEW_QUESTION':
        return '새로운 질문'
      case 'NEW_REACTION':
        return '새로운 반응'
      default:
        return 'SafeAreaBoard'
    }
  }

  // 메시지 본문 생성 (notification_type에 따라 변형 가능)
  const getMessageBody = async (n: Notification): Promise<string> => {
    switch (n.notification_type) {
      case 'NEW_QUESTION':
        if (n.arguments?.question_id) {
          return `Q.${await getQuestionTitle(n.arguments?.question_id as number)}`
        }
        return `새로운 질문이 등록되었습니다.`
      case 'NEW_REACTION':
        if (n.arguments?.post_id) {
          return `내 글에 ${await getUserNickname(n.arguments?.reaction_id as number)}님이 하트를 눌렀어요.`
        }
        return `내 글에 누군가 반응했어요!`
      default:
        return '알림이 도착했습니다.'
    }
  }

  const bodyText = await getMessageBody(notif)
  const titleText = await getMessageTitle(notif)

  // 푸시 대상 fcm_token 목록 가져오기
  let fcmTokens: string[] = []

  if (notif.is_for_all) {
    const { data, error } = await supabase
      .from('profiles')
      .select('fcm_token')
      .not('fcm_token', 'is', null)

    if (error) throw error
    fcmTokens = data.map((row) => row.fcm_token)
  } else if (notif.profile_id) {
    const { data, error } = await supabase
      .from('profiles')
      .select('fcm_token')
      .eq('id', notif.profile_id)
      .maybeSingle()

    if (error) throw error
    if (data?.fcm_token) fcmTokens = [data.fcm_token]
  }

  if (fcmTokens.length === 0) {
    console.log('보낼 FCM 토큰이 없습니다.')
    return new Response('No FCM tokens', { status: 204 })
  }

  // access token 발급
  const accessToken = await getAccessToken({
    clientEmail: serviceAccount.client_email,
    privateKey: serviceAccount.private_key,
  })

  const responses = []

  for (const token of fcmTokens) {
    const res = await fetch(
      `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${accessToken}`,
        },
        body: JSON.stringify({
          message: {
            token,
            notification: {
              title: titleText,
              body: bodyText,
            },
            data: {
              notification_type: notif.notification_type,
              arguments: JSON.stringify(notif.arguments),
            },
          },
        }),
      }
    )

    const resData = await res.json()
    if (res.status < 200 || res.status > 299) {
      console.error('FCM 에러', resData)
    }
    responses.push(resData)
  }

  console.log("알림 전송에 성공했습니다", notif)

  const { error } = await supabase
    .from('notifications')
    .update({ 'sent_at': new Date().toISOString() })
    .eq('id', notif.id)
  
  if (error) {
    console.error('알림 전송에는 성공했지만 notifications 갱신에는 실패했습니다.', error)
  }

  return new Response(JSON.stringify({ sent: responses.length }), {
    headers: { 'Content-Type': 'application/json' },
  })
})

const getAccessToken = ({
  clientEmail,
  privateKey,
}: {
  clientEmail: string
  privateKey: string
}): Promise<string> => {
  return new Promise((resolve, reject) => {
    const jwtClient = new JWT({
      email: clientEmail,
      key: privateKey,
      scopes: ['https://www.googleapis.com/auth/firebase.messaging'],
    })
    jwtClient.authorize((err, tokens) => {
      if (err) {
        reject(err)
        return
      }
      resolve(tokens!.access_token!)
    })
  })
}
